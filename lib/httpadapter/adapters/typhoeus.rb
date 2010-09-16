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
require 'typhoeus'
require 'typhoeus/request'
require 'typhoeus/response'
require 'addressable/uri'

module HTTPAdapter #:nodoc:
  class TyphoeusRequestAdapter
    def initialize(request)
      unless request.kind_of?(Typhoeus::Request)
        raise TypeError, "Expected Typhoeus::Request, got #{request.class}."
      end
      @request = request
    end

    def to_ary
      method = @request.method.to_s.upcase
      uri = @request.url.to_str
      headers = []
      @request.headers.each do |header, value|
        headers << [header, value]
      end
      body = @request.body || ""
      return [method, uri, headers, [body]]
    end

    def self.from_ary(array)
      method, uri, headers, body = array
      method = method.to_s.downcase.to_sym
      uri = Addressable::URI.parse(uri)
      headers = Hash[headers]
      merged_body = ""
      body.each do |chunk|
        merged_body += chunk
      end
      if merged_body == ''
        merged_body = nil
      end
      request = Typhoeus::Request.new(
        uri.to_str,
        :method => method,
        :headers => headers,
        :body => merged_body
      )
      return request
    end

    def self.transmit(request, connection=nil)
      method, uri, headers, body = request
      uri = Addressable::URI.parse(uri)
      typhoeus_request = self.from_ary([method, uri, headers, body])
      typhoeus_response = nil
      unless connection
        hydra = Typhoeus::Hydra.new
        connection = HTTPAdapter::Connection.new(
          uri.host, uri.inferred_port, hydra,
          :join => [:run, [], nil]
        )
      else
        http = nil
      end
      typhoeus_request.on_complete do |response|
        typhoeus_response = response
      end
      connection.connection.queue(typhoeus_request)
      connection.join
      return TyphoeusResponseAdapter.new(typhoeus_response).to_ary
    end
  end

  class TyphoeusResponseAdapter
    def initialize(response)
      unless response.kind_of?(Typhoeus::Response)
        raise TypeError, "Expected Typhoeus::Response, got #{response.class}."
      end
      @response = response
    end

    def to_ary
      status = @response.code.to_i
      headers = []
      @response.headers_hash.each do |header, value|
        # Eh? Seriously?  This is NOT a header!
        next if header =~ /^HTTP\/\d\.\d \d{3} .+$/
        if value.kind_of?(Array)
          for repeated_header_value in value
            # Header appears multiple times; common for Set-Cookie
            headers << [header, repeated_header_value]
          end
        else
          headers << [header, value]
        end
      end
      body = @response.body || ""
      return [status, headers, [body]]
    end

    def self.from_ary(array)
      status, headers, body = array
      status = status.to_i
      merged_body = ""
      body.each do |chunk|
        merged_body += chunk
      end
      response = Typhoeus::Response.new(
        :code => status,
        :headers => headers.inject('') { |a,(h,v)| a << "#{h}: #{v}\r\n"; a },
        :body => merged_body
      )
      return response
    end
  end
end
