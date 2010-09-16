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

if ([:enable_post_connection_check=, 'enable_post_connection_check='] &
    Net::HTTP.instance_methods).empty?
  class Net::HTTP
    def enable_post_connection_check=(value)
      # No-op
    end
  end
end

describe HTTPAdapter::NetHTTPRequestAdapter, 'transmitting a GET tuple' do
  before do
    @tuple = [
      'GET',
      'http://www.google.com/',
      [],
      []
    ]
    @response = HTTPAdapter.transmit(
      @tuple, HTTPAdapter::NetHTTPRequestAdapter
    )
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

describe HTTPAdapter::NetHTTPRequestAdapter, 'transmitting a GET tuple' do
  before do
    @tuple = [
      'GET',
      'https://www.google.com/',
      [],
      []
    ]
    @response = HTTPAdapter.transmit(
      @tuple, HTTPAdapter::NetHTTPRequestAdapter
    )
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

describe HTTPAdapter::NetHTTPRequestAdapter, 'transmitting with connection' do
  before do
    @connection = HTTPAdapter::Connection.new(
      'www.google.com', 80,
      Net::HTTP.new('www.google.com', 80),
      :open => [:start],
      :close => [:finish]
    )
    @connection.open
    @tuple = [
      'GET',
      'http://www.google.com/',
      [],
      []
    ]
    @response = HTTPAdapter.transmit(
      @tuple, HTTPAdapter::NetHTTPRequestAdapter, @connection
    )
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
