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

require 'httpadapter/adapters/mock'

describe HTTPAdapter::MockAdapter do
  describe 'with no response mocked' do
    before do
      @adapter = HTTPAdapter::MockAdapter.create do |request_ary, connection|
        method, uri, headers, body = request_ary
        headers.should be_any { |k, v| k.downcase == 'user-agent' }
      end
    end

    it_should_behave_like 'adapter type-checking example'

    describe 'when transmitting a request' do
      it 'should have an expectation failure' do
        (lambda do
          @adapter.transmit(['GET', 'http://www.google.com/', [], ['']])
        end).should raise_error(Spec::Expectations::ExpectationNotMetError)
      end

      it 'should meet all expectations' do
        response = @adapter.transmit([
          'GET',
          'http://www.google.com/',
          [['User-Agent', 'Mock Agent']],
          ['']
        ])
        status, headers, body = response
        status.should == 200
      end
    end
  end

  describe 'with a mocked response' do
    before do
      @adapter = HTTPAdapter::MockAdapter.create do |request_ary, connection|
        method, uri, headers, body = request_ary
        headers.should be_any { |k, v| k.downcase == 'user-agent' }
        [400, [], ['']]
      end
    end

    it_should_behave_like 'adapter type-checking example'

    describe 'when transmitting a request' do
      it 'should have an expectation failure' do
        (lambda do
          @adapter.transmit(['GET', 'http://www.google.com/', [], ['']])
        end).should raise_error(Spec::Expectations::ExpectationNotMetError)
      end

      it 'should meet all expectations' do
        response = @adapter.transmit([
          'GET',
          'http://www.google.com/',
          [['User-Agent', 'Mock Agent']],
          ['']
        ])
        status, headers, body = response
        status.should == 400
      end
    end
  end
end
