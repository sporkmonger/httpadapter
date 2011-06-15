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

# Used to prevent the class/module from being loaded more than once
unless defined? HTTPAdapter::VERSION
  ##
  # A module which provides methods to aid in conversion of HTTP request and
  # response objects.  It uses tuples as a generic intermediary format.
  #
  # @example
  #   class StubAdapter
  #     include HTTPAdapter
  #   
  #     def convert_request_to_a(request_obj)
  #       return ['GET', '/', [], [""]] # Stubbed request tuple
  #     end
  #   
  #     def convert_request_from_a(request_ary)
  #       return Object.new # Stubbed request object
  #     end
  #   
  #     def convert_response_to_a(response_obj)
  #       return [200, [], ['']] # Stubbed response tuple
  #     end
  # 
  #     def convert_response_from_a(response_ary)
  #       return Object.new # Stubbed response object
  #     end
  # 
  #     def fetch_resource(request_ary, connection=nil)
  #       return [200, [], ['']] # Stubbed response tuple from server
  #     end
  #   end
  module HTTPAdapter
    ##
    module VERSION
      MAJOR = 1
      MINOR = 0
      TINY  = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
