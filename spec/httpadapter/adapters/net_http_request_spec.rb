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

require 'httpadapter/adapters/net_http'

describe HTTPAdapter::NetHTTPRequestAdapter do
  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [], [42]], HTTPAdapter::NetHTTPRequestAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid request' do
    (lambda do
      HTTPAdapter.adapt_request(
        42, HTTPAdapter::NetHTTPRequestAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for the bogus HTTP method' do
    (lambda do
      tuple = [
        'BOGUS',
        'http://www.example.com/path?query',
        [
          ['Accept', 'application/json'],
          ['Content-Type', 'application/json; charset=utf-8'],
          ['Content-Length', '27']
        ],
        ['{"three":3,', '"two":2,', '"one":1}']
      ]
      HTTPAdapter.specialize_request(
        tuple, HTTPAdapter::NetHTTPRequestAdapter
      )
    end).should raise_error(ArgumentError)
  end
end

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Get' do
  before do
    @request = Net::HTTP::Get.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      @request, HTTPAdapter::NetHTTPRequestAdapter
    )
    @method, @uri, @headers, @body = @result
  end

  it 'should convert the HTTP method properly' do
    @method.should == 'GET'
  end

  it 'should convert the URI properly' do
    @uri.should == '/path/to/resource'
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

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Get with :uri option set' do
  before do
    @request = Net::HTTP::Get.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      HTTPAdapter::NetHTTPRequestAdapter.new(
        @request,
        :uri =>
          Addressable::URI.parse('http://www.example.com/path/to/resource')
      )
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

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Get with :uri option set' do
  before do
    @request = Net::HTTP::Get.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      HTTPAdapter::NetHTTPRequestAdapter.new(
        @request,
        :uri => 'http://www.example.com/path/to/resource'
      )
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

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Get with :uri option set' do
  before do
    @request = Net::HTTP::Get.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      HTTPAdapter::NetHTTPRequestAdapter.new(
        @request,
        :host => 'www.example.com'
      )
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

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Get with :uri option set' do
  before do
    @request = Net::HTTP::Get.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      HTTPAdapter::NetHTTPRequestAdapter.new(
        @request,
        :host => 'www.example.com',
        :port => 8080
      )
    )
    @method, @uri, @headers, @body = @result
  end

  it 'should convert the HTTP method properly' do
    @method.should == 'GET'
  end

  it 'should convert the URI properly' do
    @uri.should == 'http://www.example.com:8080/path/to/resource'
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

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Get with :uri option set' do
  before do
    @request = Net::HTTP::Get.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @result = HTTPAdapter.adapt_request(
      HTTPAdapter::NetHTTPRequestAdapter.new(
        @request,
        :scheme => 'https',
        :host => 'www.example.com',
        :port => 443
      )
    )
    @method, @uri, @headers, @body = @result
  end

  it 'should convert the HTTP method properly' do
    @method.should == 'GET'
  end

  it 'should convert the URI properly' do
    @uri.should == 'https://www.example.com/path/to/resource'
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

describe HTTPAdapter::NetHTTPRequestAdapter,
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
      @tuple, HTTPAdapter::NetHTTPRequestAdapter
    )
  end

  it 'should convert the HTTP method properly' do
    @request.method.should == 'GET'
  end

  it 'should convert the URI properly' do
    @request.path.should == '/path?query'
  end

  it 'should convert the headers properly' do
    accept = nil
    @request.canonical_each do |header, value|
      header.should be_kind_of(String)
      value.should be_kind_of(String)
      accept = value if header == 'Accept'
    end
    accept.should == 'application/json'
  end

  it 'should convert the body properly' do
    @request.body.should == ''
  end
end

describe HTTPAdapter::NetHTTPRequestAdapter,
    'converting from Net::HTTP::Post' do
  before do
    @request = Net::HTTP::Post.new('/path/to/resource')
    @request['Accept'] = 'application/json'
    @request['Content-Type'] = 'application/json; charset=utf-8'
    @request.body = '{"three":3,"two":2,"one":1}'
    @result = HTTPAdapter.adapt_request(
      @request, HTTPAdapter::NetHTTPRequestAdapter
    )
    @method, @uri, @headers, @body = @result
  end

  it 'should convert the HTTP method properly' do
    @method.should == 'POST'
  end

  it 'should convert the URI properly' do
    @uri.should == '/path/to/resource'
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

describe HTTPAdapter::NetHTTPRequestAdapter,
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
      @tuple, HTTPAdapter::NetHTTPRequestAdapter
    )
  end

  it 'should convert the HTTP method properly' do
    @request.method.should == 'POST'
  end

  it 'should convert the URI properly' do
    @request.path.should == '/path?query'
  end

  it 'should convert the headers properly' do
    accept = nil
    content_type = nil
    @request.canonical_each do |header, value|
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
