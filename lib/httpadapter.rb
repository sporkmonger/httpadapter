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

module HTTPAdapter #:nodoc:
  ##
  # Converts an HTTP request object to a simple tuple.
  #
  # @param [Object, #to_ary] request
  #   The request object to be converted.  The request may either implement
  #   the <code>#to_ary</code> method directly or alternately, an optional
  #   adapter class may be provided.  The adapter must accept the request
  #   object as a parameter and provide the <code>#to_ary</code> method.
  #
  # @return [Array] The tuple that the request was converted to.
  def self.adapt_request(request, adapter=nil)
    # Temporarily wrap the request if there's an adapter
    request = adapter.new(request) if adapter
    if request.respond_to?(:to_ary)
      converted_request = request.to_ary
    else
      # Can't use #to_a because some versions of Ruby define #to_a on Object
      raise TypeError,
        "Expected adapter or request to implement #to_ary."
    end
    return self.verified_request(converted_request)
  end

  ##
  # Converts an HTTP response object to a simple tuple.
  #
  # @param [Object, #to_ary] response
  #   The response object to be converted.  The response may either implement
  #   the <code>#to_ary</code> method directly or alternately, an optional
  #   adapter class may be provided.  The adapter must accept the response
  #   object as a parameter and provide the <code>#to_ary</code> method.
  #
  # @return [Array] The tuple that the reponse was converted to.
  def self.adapt_response(response, adapter=nil)
    # Temporarily wrap the response if there's an adapter
    response = adapter.new(response) if adapter
    if response.respond_to?(:to_ary)
      converted_response = response.to_ary
    else
      # Can't use #to_a because some versions of Ruby define #to_a on Object
      raise TypeError,
        "Expected adapter or response to implement #to_ary."
    end
    return self.verified_response(converted_response)
  end

  ##
  # Converts a tuple to a specific HTTP implementation's request format.
  #
  # @param [Array] request
  #   The request object to be converted.  The request object must be a tuple
  #   with a length of 4.  The first element must be the request method.
  #   The second element must be the URI.  The URI may be relative.  The third
  #   element contains the headers.  It must respond to <code>#each</code> and
  #   iterate over the header names and values.  The fourth element must be
  #   the body.  It must respond to <code>#each</code> but may not be a
  #   <code>String</code>.  It should emit <code>String</code> objects.
  # @param [#from_ary] adapter
  #   The adapter object that will convert to a tuple.  It must respond to
  #   <code>#from_ary</code>.  Typically a reference to a class is used.
  #
  # @return [Array] The implementation-specific request object.
  def self.specialize_request(request, adapter)
    request = self.verified_request(request)
    if adapter.respond_to?(:from_ary)
      return adapter.from_ary(request)
    else
      raise TypeError,
        "Expected adapter to implement .from_ary."
    end
  end

  ##
  # Converts a tuple to a specific HTTP implementation's response format.
  #
  # @param [Array] response
  #   The response object to be converted.  The response object must be a
  #   tuple with a length of 3.  The first element must be the HTTP status
  #   code.  The second element contains the headers.  It must respond to
  #   <code>#each</code> and iterate over the header names and values.  The
  #   third element must be the body.  It must respond to <code>#each</code>
  #   but may not be a <code>String</code>.  It should emit
  #   <code>String</code> objects. This is essentially the same format that
  #   Rack uses.
  # @param [#from_ary] adapter
  #   The adapter object that will convert to a tuple.  It must respond to
  #   <code>#from_ary</code>.  Typically a reference to a class is used.
  #
  # @return [Array] The implementation-specific response object.
  def self.specialize_response(response, adapter)
    response = self.verified_response(response)
    if adapter.respond_to?(:from_ary)
      return adapter.from_ary(response)
    else
      raise TypeError, 'Expected adapter to implement .from_ary.'
    end
  end

  ##
  # Transmits a request.
  #
  # @param [Array] request
  #   The request that will be sent.
  # @param [#transmit] adapter
  #   The adapter object that will perform the transmission of the HTTP
  #   request.  It must respond to <code>#transmit</code>.  Typically a
  #   reference to a class is used.
  # @param [HTTPAdapter::Connection] connection
  #   An object representing a connection.  This object represents an open
  #   HTTP connection that is used to make multiple HTTP requests.
  # @return [Array]
  #   The response given by the server.
  #
  # @return [Array] The implementation-specific response object.
  def self.transmit(request, adapter, connection=nil)
    request = self.verified_request(request)
    if connection && !connection.kind_of?(HTTPAdapter::Connection)
      raise TypeError,
        "Expected HTTPAdapter::Connection, got #{connection.class}."
    end
    if adapter.respond_to?(:transmit)
      response = adapter.transmit(request, connection)
      return self.verified_response(response)
    else
      raise TypeError, 'Expected adapter to implement .transmit.'
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
        raise TypeError, "Expected headers to respond to #each."
      end
      if body.kind_of?(String)
        raise TypeError,
          'Body must not be a String; it must respond to #each and ' +
          'emit String values.'
      end
      # Can't verify that all chunks are Strings because #each may be
      # effectively destructive.
      if !body.respond_to?(:each)
        raise TypeError, "Expected body to respond to #each."
      end
    else
      raise TypeError,
        "Expected tuple of [method, uri, headers, body]."
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
        raise TypeError, "Expected headers to respond to #each."
      end
      if body.kind_of?(String)
        raise TypeError,
          'Body must not be a String; it must respond to #each and ' +
          'emit String values.'
      end
      # Can't verify that all chunks are Strings because #each may be
      # effectively destructive.
      if !body.respond_to?(:each)
        raise TypeError, "Expected body to respond to #each."
      end
    else
      raise TypeError,
        "Expected tuple of [status, headers, body]."
    end
    return [status, headers, body]
  end
end
