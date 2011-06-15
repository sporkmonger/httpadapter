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

module HTTPAdapter
  class TyphoeusAdapter
    include HTTPAdapter

    def convert_request_to_a(request_obj)
      unless request_obj.kind_of?(Typhoeus::Request)
        raise TypeError,
          "Expected Typhoeus::Request, got #{request_obj.class}."
      end
      method = request_obj.method.to_s.upcase
      uri = request_obj.url.to_str
      headers = []
      request_obj.headers.each do |header, value|
        headers << [header, value]
      end
      body = request_obj.body || ""
      return [method, uri, headers, [body]]
    end

    def convert_request_from_a(request_ary)
      method, uri, headers, body = request_ary
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

    def convert_response_to_a(response_obj)
      unless response_obj.kind_of?(Typhoeus::Response)
        raise TypeError,
          "Expected Typhoeus::Response, got #{response_obj.class}."
      end
      status = response_obj.code.to_i
      headers = []
      response_obj.headers_hash.each do |header, value|
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
      body = response_obj.body || ""
      return [status, headers, [body]]
    end

    def convert_response_from_a(request_ary)
      status, headers, body = request_ary
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

    def fetch_resource(request_ary, connection=nil)
      method, uri, headers, body = request_ary
      uri = Addressable::URI.parse(uri)
      typhoeus_request = self.convert_request_from_a(
        [method, uri, headers, body]
      )
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
      return self.convert_response_to_a(typhoeus_response)
    end
  end
end
