# Copyright (C) 2010 Google Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'spec_helper'

require 'httpadapter/adapters/typhoeus'

describe HTTPAdapter::TyphoeusAdapter do
  before do
    @adapter = HTTPAdapter::TyphoeusAdapter.new
  end

  it_should_behave_like 'adapter type-checking example'

  describe 'when adapting a request' do
    describe 'from Typhoeus::Request for GET' do
      before do
        @request = Typhoeus::Request.new(
          'http://www.example.com/path/to/resource'
        )
        @request.headers['Accept'] = 'application/json'
        @result = @adapter.adapt_request(@request)
        @method, @uri, @headers, @body = @result
      end

      it 'should convert the HTTP method properly' do
        @method.should == 'GET'
      end

      it 'should convert the URI properly' do
        @uri.should == 'http://www.example.com/path/to/resource'
      end

      it 'should convert the headers properly' do
        accept = nil
        @headers.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          accept = value if header == 'Accept'
        end
        accept.should == 'application/json'
      end

      it 'should convert the body properly' do
        @body.each do |chunk|
          chunk.should be_kind_of(String)
        end
      end
    end

    describe 'from Typhoeus::Request for POST' do
      before do
        @request = Typhoeus::Request.new(
          'http://www.example.com/path/to/resource',
          :method => :post
        )
        @request.headers['Accept'] = 'application/json'
        @request.headers['Content-Type'] = 'application/json; charset=utf-8'
        @request.body = '{"three":3,"two":2,"one":1}'
        @result = @adapter.adapt_request(@request)
        @method, @uri, @headers, @body = @result
      end

      it 'should convert the HTTP method properly' do
        @method.should == 'POST'
      end

      it 'should convert the URI properly' do
        @uri.should == 'http://www.example.com/path/to/resource'
      end

      it 'should convert the headers properly' do
        accept = nil
        content_type = nil
        @headers.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          accept = value if header == 'Accept'
          content_type = value if header == 'Content-Type'
        end
        accept.should == 'application/json'
        content_type.should == 'application/json; charset=utf-8'
      end

      it 'should convert the body properly' do
        merged_body = ""
        @body.each do |chunk|
          chunk.should be_kind_of(String)
          merged_body += chunk
        end
        merged_body.should == '{"three":3,"two":2,"one":1}'
      end
    end
  end

  describe 'when specializing a request' do
    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(
          ['GET', '/', [], [42]]
        )
      end).should raise_error(TypeError)
    end

    describe 'from a GET tuple' do
      before do
        @tuple = [
          'GET',
          'http://www.example.com/path?query',
          [
            ['Accept', 'application/json']
          ],
          []
        ]
        @request = @adapter.specialize_request(@tuple)
      end

      it 'should convert the HTTP method properly' do
        @request.method.should == :get
      end

      it 'should convert the URI properly' do
        @request.url.should == 'http://www.example.com/path?query'
      end

      it 'should convert the headers properly' do
        accept = nil
        @request.headers.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          accept = value if header == 'Accept'
        end
        accept.should == 'application/json'
      end

      it 'should convert the body properly' do
        @request.body.should == nil
      end
    end

    describe 'from a POST tuple' do
      before do
        @tuple = [
          'POST',
          'http://www.example.com/path?query',
          [
            ['Accept', 'application/json'],
            ['Content-Type', 'application/json; charset=utf-8'],
            ['Content-Length', '27']
          ],
          ['{"three":3,', '"two":2,', '"one":1}']
        ]
        @request = @adapter.specialize_request(@tuple)
      end

      it 'should convert the HTTP method properly' do
        @request.method.should == :post
      end

      it 'should convert the URI properly' do
        @request.url.should == 'http://www.example.com/path?query'
      end

      it 'should convert the headers properly' do
        accept = nil
        content_type = nil
        @request.headers.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          accept = value if header == 'Accept'
          content_type = value if header == 'Content-Type'
        end
        accept.should == 'application/json'
        content_type.should == 'application/json; charset=utf-8'
      end

      it 'should convert the body properly' do
        @request.body.should == '{"three":3,"two":2,"one":1}'
      end
    end
  end

  describe 'when adapting a response' do
    describe 'from Typhoeus::Response' do
      before do
        @response = Typhoeus::Response.new(
          :code => 200,
          :headers => <<-HEADERS,
    Content-Type: application/json; charset=utf-8
    Content-Length: 27
    HEADERS
          :body => '{"three":3,"two":2,"one":1}'
        )
        @result = @adapter.adapt_response(@response)
        @status, @headers, @body = @result
      end

      it 'should convert the HTTP status properly' do
        @status.should == 200
      end

      it 'should convert the headers properly' do
        content_type = nil
        @headers.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          content_type = value if header == 'Content-Type'
        end
        content_type.should == 'application/json; charset=utf-8'
      end

      it 'should convert the body properly' do
        merged_body = ""
        @body.each do |chunk|
          merged_body += chunk
          chunk.should be_kind_of(String)
        end
        merged_body.should == '{"three":3,"two":2,"one":1}'
      end
    end
  end

  describe 'when specializing a response' do
    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response(
          [200, [], [42]]
        )
      end).should raise_error(TypeError)
    end

    describe 'from a 200 tuple' do
      before do
        @tuple = [
          200,
          [
            ['Content-Type', 'application/json; charset=utf-8'],
            ['Content-Length', '27']
          ],
          ['{"three":3,"two":2,"one":1}']
        ]
        @response = @adapter.specialize_response(@tuple)
      end

      it 'should convert the HTTP status properly' do
        @response.code.to_i.should == 200
      end

      it 'should convert the headers properly' do
        content_type = nil
        @response.headers_hash.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          content_type = value if header == 'Content-Type'
        end
        content_type.should == 'application/json; charset=utf-8'
      end

      it 'should convert the body properly' do
        @response.body.should == '{"three":3,"two":2,"one":1}'
      end
    end

    describe 'from a 200 tuple' do
      before do
        @tuple = [
          500,
          [
            ['Content-Type', 'text/html'],
            ['Content-Length', '28']
          ],
          ['<html><body>', '42', '</body></html>']
        ]
        @response = @adapter.specialize_response(@tuple)
      end

      it 'should convert the HTTP status properly' do
        @response.code.to_i.should == 500
      end

      it 'should convert the headers properly' do
        content_type = nil
        @response.headers_hash.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          content_type = value if header == 'Content-Type'
        end
        content_type.should == 'text/html'
      end

      it 'should convert the body properly' do
        @response.body.should == '<html><body>42</body></html>'
      end
    end
  end

  describe 'when transmitting a request' do
    describe 'with a GET tuple' do
      before do
        @tuple = [
          'GET',
          'http://www.google.com/',
          [],
          []
        ]
        @response = @adapter.transmit(@tuple)
        @status, @headers, @chunked_body = @response
        @body = ''
        @chunked_body.each do |chunk|
          @body += chunk
        end
      end

      it 'should have the correct status' do
        @status.should == 200
      end

      it 'should have response headers' do
        @headers.should_not be_empty
      end

      it 'should have a response body' do
        @body.length.should > 0
      end
    end

    describe 'with connection' do
      before do
        @connection = HTTPAdapter::Connection.new(
          'www.google.com', 80,
          Typhoeus::Hydra.new,
          :join => [:run, [], nil]
        )
        @connection.open
        @tuple = [
          'GET',
          'http://www.google.com/',
          [],
          []
        ]
        @response = @adapter.transmit(@tuple, @connection)
        @status, @headers, @chunked_body = @response
        @body = ''
        @chunked_body.each do |chunk|
          @body += chunk
        end
      end

      after do
        @connection.close
      end

      it 'should have the correct status' do
        @status.should == 200
      end

      it 'should have response headers' do
        @headers.should_not be_empty
      end

      it 'should have a response body' do
        @body.length.should > 0
      end
    end
  end
end


