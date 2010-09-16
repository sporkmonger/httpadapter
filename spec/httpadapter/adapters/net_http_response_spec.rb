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

describe HTTPAdapter::NetHTTPResponseAdapter do
  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [], [42]], HTTPAdapter::NetHTTPResponseAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid response' do
    (lambda do
      HTTPAdapter.adapt_response(
        42, HTTPAdapter::NetHTTPResponseAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for the bogus HTTP status code' do
    (lambda do
      tuple = [
        'BOGUS',
        [
          ['Content-Type', 'application/json; charset=utf-8'],
          ['Content-Length', '27']
        ],
        ['{"three":3,', '"two":2,', '"one":1}']
      ]
      HTTPAdapter.specialize_response(
        tuple, HTTPAdapter::NetHTTPResponseAdapter
      )
    end).should raise_error(ArgumentError)
  end
end

describe HTTPAdapter::NetHTTPResponseAdapter,
    'converting from Net::HTTPOK' do
  before do
    @response = Net::HTTPOK.new('1.1', '200', 'OK')
    @response['Content-Type'] = 'application/json; charset=utf-8'
    @response['Content-Length'] = '27'

    # Ugh
    @response.instance_variable_set('@read', true)
    @response.instance_variable_set('@body', '{"three":3,"two":2,"one":1}')

    @result = HTTPAdapter.adapt_response(
      @response, HTTPAdapter::NetHTTPResponseAdapter
    )
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

describe HTTPAdapter::NetHTTPResponseAdapter,
    'converting from a 200 tuple' do
  before do
    @tuple = [
      200,
      [
        ['Content-Type', 'application/json; charset=utf-8'],
        ['Content-Length', '27']
      ],
      ['{"three":3,"two":2,"one":1}']
    ]
    @response = HTTPAdapter.specialize_response(
      @tuple, HTTPAdapter::NetHTTPResponseAdapter
    )
  end

  it 'should be the correct type' do
    @response.should be_kind_of(Net::HTTPOK)
  end

  it 'should convert the HTTP status properly' do
    @response.code.to_i.should == 200
  end

  it 'should convert the headers properly' do
    content_type = nil
    @response.canonical_each do |header, value|
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

describe HTTPAdapter::NetHTTPResponseAdapter,
    'converting from a 200 tuple' do
  before do
    @tuple = [
      500,
      [
        ['Content-Type', 'text/html'],
        ['Content-Length', '28']
      ],
      ['<html><body>', '42', '</body></html>']
    ]
    @response = HTTPAdapter.specialize_response(
      @tuple, HTTPAdapter::NetHTTPResponseAdapter
    )
  end

  it 'should be the correct type' do
    @response.should be_kind_of(Net::HTTPInternalServerError)
  end

  it 'should convert the HTTP status properly' do
    @response.code.to_i.should == 500
  end

  it 'should convert the headers properly' do
    content_type = nil
    @response.canonical_each do |header, value|
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
