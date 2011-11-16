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


require 'httpadapter'

module HTTPAdapter
  ##
  # A simple module for mocking the transmit method on an adapter.
  #
  # @example
  #   # Using RSpec, verify that the request being sent includes a user agent.
  #   adapter = HTTPAdapter::MockAdapter.create do |request_ary, connection|
  #     method, uri, headers, body = request_ary
  #     headers.should be_any { |k, v| k.downcase == 'user-agent' }
  #   end
  module MockAdapter
    def self.create(&block)
      adapter = Class.new do
        include HTTPAdapter

        define_method('fetch_resource') do |*params|
          response = block.call(*params)
          if response.respond_to?(:each)
            return response
          else
            return [200, [], ['']]
          end
        end
      end
      return adapter.new
    end
  end
end
