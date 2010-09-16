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

describe HTTPAdapter::TyphoeusRequestAdapter do
  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [], [42]], HTTPAdapter::TyphoeusRequestAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid request' do
    (lambda do
      HTTPAdapter.adapt_request(
        42, HTTPAdapter::TyphoeusRequestAdapter
      )
    end).should raise_error(TypeError)
  end
end

describe HTTPAdapter::TyphoeusRequestAdapter,
    'converting from Typhoeus::Request for GET' do
  before do
    @request = Typhoeus::Request.new(
      'http://www.example.com/path/to/resource'
    )
    @request.headers['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      @request, HTTPAdapter::TyphoeusRequestAdapter
    )
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

describe HTTPAdapter::TyphoeusRequestAdapter,
    'converting from a GET tuple' do
  before do
    @tuple = [
      'GET',
      'http://www.example.com/path?query',
      [
        ['Accept', 'application/json']
      ],
      []
    ]
    @request = HTTPAdapter.specialize_request(
      @tuple, HTTPAdapter::TyphoeusRequestAdapter
    )
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

describe HTTPAdapter::TyphoeusRequestAdapter,
    'converting from Typhoeus::Request for POST' do
  before do
    @request = Typhoeus::Request.new(
      'http://www.example.com/path/to/resource',
      :method => :post
    )
    @request.headers['Accept'] = 'application/json'
    @request.headers['Content-Type'] = 'application/json; charset=utf-8'
    @request.body = '{"three":3,"two":2,"one":1}'
    @result = HTTPAdapter.adapt_request(
      @request, HTTPAdapter::TyphoeusRequestAdapter
    )
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

describe HTTPAdapter::TyphoeusRequestAdapter,
    'converting from a POST tuple' do
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
    @request = HTTPAdapter.specialize_request(
      @tuple, HTTPAdapter::TyphoeusRequestAdapter
    )
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
