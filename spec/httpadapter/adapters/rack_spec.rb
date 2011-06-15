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
require 'spec/httpadapter/adapter_type_checking_spec'

require 'httpadapter/adapters/rack'

describe HTTPAdapter::RackAdapter do
  before do
    @adapter = HTTPAdapter::RackAdapter.new
  end

  it_should_behave_like 'adapter type-checking example'

  describe 'when adapting a request' do
    describe 'from Rack::Request for GET' do
      before do
        @body_io = StringIO.new
        @env = {
          # PEP333 variables
          'REQUEST_METHOD' => 'GET',
          'SERVER_NAME' => 'www.example.com',
          'SERVER_PORT' => '80',
          'SCRIPT_NAME' => '',
          'PATH_INFO' => '/path/to/resource',
          'QUERY_STRING' => '',

          # Rack-specific variables
          'rack.version' => Rack::VERSION,
          'rack.input' => @body_io,
          'rack.errors' => STDERR,
          'rack.multithread' => true,
          'rack.multiprocess' => true,
          'rack.run_once' => false,
          'rack.url_scheme' => 'http',

          # HTTP headers
          'HTTP_ACCEPT' => 'application/json'
        }
        @request = Rack::Request.new(@env)
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

    describe 'from Rack::Request for POST' do
      before do
        @body_io = StringIO.new('{"three":3,"two":2,"one":1}')
        @env = {
          # PEP333 variables
          'REQUEST_METHOD' => 'POST',
          'SERVER_NAME' => 'www.example.com',
          'SERVER_PORT' => '80',
          'SCRIPT_NAME' => '',
          'PATH_INFO' => '/path/to/resource',
          'QUERY_STRING' => '',

          # Rack-specific variables
          'rack.version' => Rack::VERSION,
          'rack.input' => @body_io,
          'rack.errors' => STDERR,
          'rack.multithread' => true,
          'rack.multiprocess' => true,
          'rack.run_once' => false,
          'rack.url_scheme' => 'http',

          # HTTP headers
          'HTTP_ACCEPT' => 'application/json',
          'HTTP_CONTENT_TYPE' => 'application/json; charset=utf-8'
        }
        @request = Rack::Request.new(@env)
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
        @adapter.specialize_request(['GET', '/', [], [42]])
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
        @request.request_method.should == 'GET'
      end

      it 'should convert the URI properly' do
        @request.url.should == 'http://www.example.com/path?query'
      end

      it 'should convert the headers properly' do
        @request.env['HTTP_ACCEPT'].should == 'application/json'
      end

      it 'should convert the body properly' do
        @request.body.read.should == ''
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
        @request.request_method.should == 'POST'
      end

      it 'should convert the URI properly' do
        @request.url.should == 'http://www.example.com/path?query'
      end

      it 'should convert the headers properly' do
        accept = nil
        content_type = nil
        @request.env['HTTP_ACCEPT'].should == 'application/json'
        @request.env['HTTP_CONTENT_TYPE'].should ==
          'application/json; charset=utf-8'
      end

      it 'should convert the body properly' do
        @request.body.read.should == '{"three":3,"two":2,"one":1}'
      end
    end
  end

  describe 'when adapting a response' do
    it 'should raise an error for converting from an invalid response' do
      (lambda do
        @adapter.adapt_response(42)
      end).should raise_error(TypeError)
    end

    describe 'from Rack::Response' do
      before do
        @response = Rack::Response.new(
          ['{"three":3,"two":2,"one":1}'],
          200,
          {
            'Content-Type' => 'application/json; charset=utf-8',
            'Content-Length' => '27'
          }
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
        @response.status.to_i.should == 200
      end

      it 'should parse the content length properly' do
        @response.length.to_i.should == 27
      end

      it 'should convert the headers properly' do
        content_type = nil
        @response.header.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          content_type = value if header == 'Content-Type'
        end
        content_type.should == 'application/json; charset=utf-8'
      end

      it 'should convert the body properly' do
        merged_body = ""
        @response.body.each do |chunk|
          merged_body += chunk
        end
        merged_body.should == '{"three":3,"two":2,"one":1}'
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
        @response.status.to_i.should == 500
      end

      it 'should convert the headers properly' do
        content_type = nil
        @response.header.each do |header, value|
          header.should be_kind_of(String)
          value.should be_kind_of(String)
          content_type = value if header == 'Content-Type'
        end
        content_type.should == 'text/html'
      end

      it 'should convert the body properly' do
        merged_body = ""
        @response.body.each do |chunk|
          merged_body += chunk
        end
        merged_body.should == '<html><body>42</body></html>'
      end
    end
  end

  describe 'when transmitting a request' do
    it 'should raise an error indicating that transmission is not possible' do
      (lambda do
        @adapter.transmit(['GET', 'http://www.google.com/', [], ['']])
      end).should raise_error(NotImplementedError)
    end
  end
end
