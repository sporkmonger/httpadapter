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

require 'httpadapter'

class StubAdapter
  include HTTPAdapter

  def convert_request_to_a(request_obj)
    if request_obj == 42
      raise TypeError, "This should never be fourty-two."
    end
    return ['GET', '/', [], [""]]
  end

  def convert_request_from_a(request_ary)
    if request_ary == 42
      raise TypeError, "This should never be fourty-two."
    end
    return :stubbed_request
  end

  def convert_response_to_a(response_obj)
    if response_obj == 42
      raise TypeError, "This should never be fourty-two."
    end
    return [200, [], ['']]
  end

  def convert_response_from_a(response_ary)
    if response_ary == 42
      raise TypeError, "This should never be fourty-two."
    end
    return :stubbed_response
  end

  def fetch_resource(request_ary, connection=nil)
    if request_ary == 42 || connection == 42
      raise TypeError, "This should never be fourty-two."
    end
    return [200, [], ['']]
  end
end

class BogusAdapter
  include HTTPAdapter
end

describe StubAdapter, 'a stubbed adapter class that does nothing' do
  before do
    @adapter = StubAdapter.new
    @request = ['GET', '/', [], ['']]
    @response = [200, [], ['']]
  end

  it_should_behave_like 'adapter type-checking example'

  it 'should convert to a stubbed request object' do
    @adapter.specialize_request(@request).should == :stubbed_request
  end

  it 'should convert to a stubbed response object' do
    @adapter.specialize_response(@response).should == :stubbed_response
  end

  it 'should convert to a stubbed request array' do
    @adapter.adapt_request(Object.new).should == @request
  end

  it 'should convert to a stubbed response array' do
    @adapter.adapt_response(Object.new).should == @response
  end
end

describe BogusAdapter, 'an empty class that does nothing' do
  before do
    @adapter = BogusAdapter.new
    @request = ['GET', '/', [], ['']]
    @response = [200, [], ['']]
  end

  it_should_behave_like 'adapter type-checking example'

  it 'should raise an error when attempting to adapt a request' do
    (lambda do
      @adapter.adapt_request(Object.new)
    end).should raise_error(TypeError)
  end

  it 'should raise an error when attempting to specialize a request' do
    (lambda do
      @adapter.specialize_request(@request)
    end).should raise_error(TypeError)
  end

  it 'should raise an error when attempting to adapt a response' do
    (lambda do
      @adapter.adapt_response(Object.new)
    end).should raise_error(TypeError)
  end

  it 'should raise an error when attempting to specialize a response' do
    (lambda do
      @adapter.specialize_response(@response)
    end).should raise_error(TypeError)
  end

  it 'should raise an error when attempting to transmit a request' do
    (lambda do
      @adapter.transmit(@request)
    end).should raise_error(TypeError)
  end
end
