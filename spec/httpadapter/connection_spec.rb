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

require 'httpadapter/connection'

class StubbedConnection
  def open
    # Does nothing
  end

  def close
    # Does nothing
  end

  def join
    # Does nothing
  end
end

describe HTTPAdapter::Connection, 'when wrapping a connection' do
  before do
    @connection = HTTPAdapter::Connection.new(
      'www.example.com', 80, StubbedConnection.new,
      :open => [:open, [], nil],
      :close => [:close, [], nil],
      :join => [:join, [], nil]
    )
  end

  it 'should be able to call open' do
    @connection.open
  end

  it 'should be able to call close' do
    @connection.close
  end

  it 'should be able to call join' do
    @connection.join
  end

  it 'should be able to obtain a reference to the wrapped connection' do
    @connection.connection.should be_kind_of(StubbedConnection)
  end
end

describe HTTPAdapter::Connection,
    'when wrapping a connection that does not implement methods' do
  it 'should perform no-ops' do
    @connection = HTTPAdapter::Connection.new(
      'www.example.com', 80, Object.new
    )
    @connection.open.should == nil
    @connection.close.should == nil
    @connection.join.should == nil
  end
end

describe HTTPAdapter::Connection,
    'when wrapping a connection using bogus parameters' do
  it 'should raise an error for invalid hostnames' do
    (lambda do
      HTTPAdapter::Connection.new(42, 80, Object.new)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for invalid port' do
    (lambda do
      HTTPAdapter::Connection.new('www.example.com', 0, Object.new)
    end).should raise_error(ArgumentError)
  end

  it 'should raise an error for invalid port' do
    (lambda do
      HTTPAdapter::Connection.new('www.example.com', 65536, Object.new)
    end).should raise_error(ArgumentError)
  end

  it 'should not raise an error for a valid port expressed as a String' do
    HTTPAdapter::Connection.new('www.example.com', '80', Object.new)
  end

  it 'should raise an error for invalid port' do
    (lambda do
      HTTPAdapter::Connection.new('www.example.com', '65536', Object.new)
    end).should raise_error(ArgumentError)
  end

  it 'should raise an error for invalid port' do
    (lambda do
      HTTPAdapter::Connection.new('www.example.com', :bogus, Object.new)
    end).should raise_error(TypeError)
  end
end
