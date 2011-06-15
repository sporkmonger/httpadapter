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


require 'httpadapter/version'
require 'httpadapter/connection'

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
  # Converts an HTTP request object to a simple tuple.
  #
  # @param [Object] request
  #   The request object to be converted.  The adapter must implement
  #   the <code>#convert_request_to_a</code> method, which takes the request
  #   object as a parameter.
  #
  # @return [Array] The tuple that the request was converted to.
  def adapt_request(request_obj)
    if self.respond_to?(:convert_request_to_a)
      converted_request = self.convert_request_to_a(request_obj)
    else
      raise TypeError,
        'Expected adapter to implement #convert_request_to_a.'
    end
    return HTTPAdapter.verified_request(converted_request)
  end

  ##
  # Converts a tuple to a specific HTTP implementation's request format.
  #
  # @param [Array] request_ary
  #   The request array to be converted.  The request array must be a tuple
  #   with a length of 4.  The first element must be the request method.
  #   The second element must be the URI.  The URI may be relative.  The third
  #   element contains the headers.  It must respond to <code>#each</code> and
  #   iterate over the header names and values.  The fourth element must be
  #   the body.  It must respond to <code>#each</code> but may not be a
  #   <code>String</code>.  It should emit <code>String</code> objects.
  #
  # @return [Array] The implementation-specific request object.
  def specialize_request(request_ary)
    request = HTTPAdapter.verified_request(request_ary)
    if self.respond_to?(:convert_request_from_a)
      return self.convert_request_from_a(request)
    else
      raise TypeError,
        'Expected adapter to implement #convert_request_from_a.'
    end
  end

  ##
  # Converts an HTTP response object to a simple tuple.
  #
  # @param [Object] response
  #   The response object to be converted.  The adapter must implement
  #   the <code>#convert_response_to_a</code> method, which takes the response
  #   object as a parameter.
  #
  # @return [Array] The tuple that the reponse was converted to.
  def adapt_response(response_obj)
    if self.respond_to?(:convert_response_to_a)
      converted_response = self.convert_response_to_a(response_obj)
    else
      raise TypeError,
        'Expected adapter to implement #convert_response_to_a.'
    end
    return HTTPAdapter.verified_response(converted_response)
  end

  ##
  # Converts a tuple to a specific HTTP implementation's response format.
  #
  # @param [Array] response_ary
  #   The response object to be converted.  The response object must be a
  #   tuple with a length of 3.  The first element must be the HTTP status
  #   code.  The second element contains the headers.  It must respond to
  #   <code>#each</code> and iterate over the header names and values.  The
  #   third element must be the body.  It must respond to <code>#each</code>
  #   but may not be a <code>String</code>.  It should emit
  #   <code>String</code> objects. This is essentially the same format that
  #   Rack uses.
  #
  # @return [Array] The implementation-specific response object.
  def specialize_response(response_ary)
    response_ary = HTTPAdapter.verified_response(response_ary)
    if self.respond_to?(:convert_response_from_a)
      return self.convert_response_from_a(response_ary)
    else
      raise TypeError,
        'Expected adapter to implement #convert_response_from_a.'
    end
  end

  ##
  # Transmits a request.
  #
  # @param [Array] request_ary
  #   The request tuple that will be sent.
  # @param [HTTPAdapter::Connection] connection
  #   An object representing a connection.  This object represents an open
  #   HTTP connection that is used to make multiple HTTP requests.
  # @return [Array]
  #   The response given by the server.
  #
  # @return [Array] A tuple representing the response from the server.
  def transmit(request_ary, connection=nil)
    request_ary = HTTPAdapter.verified_request(request_ary)
    if connection && !connection.kind_of?(HTTPAdapter::Connection)
      raise TypeError,
        "Expected HTTPAdapter::Connection, got #{connection.class}."
    end
    if self.respond_to?(:fetch_resource)
      response_ary = self.fetch_resource(request_ary, connection)
      return HTTPAdapter.verified_response(response_ary)
    else
      raise TypeError, 'Expected adapter to implement .fetch_resource.'
    end
  end

  ##
  # Verifies a request tuple matches the specification.
  #
  # @param [Array] request
  #   The request object to be verified.
  #
  # @return [Array] The tuple, after normalization.
  def self.verified_request(request)
    if !request.kind_of?(Array)
      raise TypeError, "Expected Array, got #{request.class}."
    end
    if request.size == 4
      # Verify that the request object matches the specification
      method, uri, headers, body = request
      method = method.to_str if method.respond_to?(:to_str)
      # Special-casing symbols here
      method = method.to_s if method.kind_of?(Symbol)
      if !method.kind_of?(String)
        raise TypeError,
          "Expected String, got #{method.class}."
      end
      method = method.upcase
      if uri.respond_to?(:to_str)
        uri = uri.to_str
      else
        raise TypeError, "Expected String, got #{uri.class}."
      end
      original_headers, headers = headers, []
      if original_headers.respond_to?(:each)
        original_headers.each do |header, value|
          if header.respond_to?(:to_str)
            header = header.to_str
          else
            raise TypeError, "Expected String, got #{header.class}."
          end
          if value.respond_to?(:to_str)
            value = value.to_str
          else
            raise TypeError, "Expected String, got #{value.class}."
          end
          headers << [header, value]
        end
      else
        raise TypeError, 'Expected headers to respond to #each.'
      end
      if body.kind_of?(String)
        raise TypeError,
          'Body must not be a String; it must respond to #each and ' +
          'emit String values.'
      end
      # Can't verify that all chunks are Strings because #each may be
      # effectively destructive.
      if !body.respond_to?(:each)
        raise TypeError, 'Expected body to respond to #each.'
      end
    else
      raise TypeError,
        "Expected tuple of [method, uri, headers, body], " +
        "got #{request.inspect}."
    end
    return [method, uri, headers, body]
  end

  ##
  # Verifies a response tuple matches the specification.
  #
  # @param [Array] response
  #   The response object to be verified.
  #
  # @return [Array] The tuple, after normalization.
  def self.verified_response(response)
    if !response.kind_of?(Array)
      raise TypeError, "Expected Array, got #{response.class}."
    end
    if response.size == 3
      # Verify that the response object matches the specification
      status, headers, body = response
      status = status.to_i if status.respond_to?(:to_i)
      if !status.kind_of?(Integer)
        raise TypeError, "Expected Integer, got #{status.class}."
      end
      original_headers, headers = headers, []
      if original_headers.respond_to?(:each)
        original_headers.each do |header, value|
          if header.respond_to?(:to_str)
            header = header.to_str
          else
            raise TypeError, "Expected String, got #{header.class}."
          end
          if value.respond_to?(:to_str)
            value = value.to_str
          else
            raise TypeError, "Expected String, got #{value.class}."
          end
          headers << [header, value]
        end
      else
        raise TypeError, 'Expected headers to respond to #each.'
      end
      if body.kind_of?(String)
        raise TypeError,
          'Body must not be a String; it must respond to #each and ' +
          'emit String values.'
      end
      # Can't verify that all chunks are Strings because #each may be
      # effectively destructive.
      if !body.respond_to?(:each)
        raise TypeError, 'Expected body to respond to #each.'
      end
    else
      raise TypeError,
        "Expected tuple of [status, headers, body], got #{response.inspect}."
    end
    return [status, headers, body]
  end
end
