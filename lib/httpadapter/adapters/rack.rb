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
require 'rack'
require 'rack/request'
require 'rack/response'
require 'addressable/uri'

module HTTPAdapter #:nodoc:
  class RackRequestAdapter
    def initialize(request, error_stream=STDERR)
      unless request.kind_of?(Rack::Request)
        raise TypeError, "Expected Rack::Request, got #{request.class}."
      end
      @request = request
      @error_stream = error_stream
    end

    def to_ary
      method = @request.request_method.to_s.upcase
      uri = Addressable::URI.parse(@request.url.to_s).normalize.to_s
      headers = []
      @request.env.each do |parameter, value|
        next if parameter !~ /^HTTP_/
        # Ugh, lossy canonicalization again
        header = (parameter.gsub(/^HTTP_/, '').split('_').map do |chunk|
          chunk.capitalize
        end).join('-')
        headers << [header, value]
      end
      return [method, uri, headers, @request.body]
    end

    def self.from_ary(array)
      # These contortions are really obnoxious; lossiness is bad!
      method, uri, headers, body = array
      env = {}
      method = method.to_s.upcase
      uri = Addressable::URI.parse(uri)
      body_io = StringIO.new
      body.each do |chunk|
        unless chunk.kind_of?(String)
          raise TypeError, "Expected String, got #{chunk.class}."
        end
        body_io.write(chunk)
      end
      body_io.rewind

      # PEP333 variables
      env['REQUEST_METHOD'] = method
      env['SERVER_NAME'] = uri.host || ''
      env['SERVER_PORT'] = uri.port || '80'
      env['SCRIPT_NAME'] = ''
      env['PATH_INFO'] = uri.path
      env['QUERY_STRING'] = uri.query || ''

      # Rack-specific variables
      env['rack.version'] = Rack::VERSION
      env['rack.input'] = body_io
      env['rack.errors'] = @error_stream
      env['rack.multithread'] = true # maybe?
      env['rack.multiprocess'] = true # maybe?
      env['rack.run_once'] = false
      env['rack.url_scheme'] = uri.scheme || 'http'

      headers.each do |header, value|
        case header.downcase
        when 'content-length'
          env['CONTENT_LENGTH'] = value
        when 'content-type'
          env['CONTENT_TYPE'] = value
        end
        env['HTTP_' + header.gsub(/\-/, "_").upcase] = value
      end
      request = Rack::Request.new(env)
      return request
    end

    def self.transmit(request, connection=nil)
      raise NotImplementedError,
        'No HTTP client implementation available to transmit a Rack::Request.'
    end
  end

  class RackResponseAdapter
    def initialize(response)
      unless response.kind_of?(Rack::Response)
        raise TypeError, "Expected Rack::Response, got #{response.class}."
      end
      @response = response
    end

    def to_ary
      return @response.finish
    end

    def self.from_ary(array)
      status, headers, body = array
      status = status.to_i
      body.each do |chunk|
        # Purely for strict type-checking
        unless chunk.kind_of?(String)
          raise TypeError, "Expected String, got #{chunk.class}."
        end
      end
      response = Rack::Response.new(body, status, Hash[headers])
      return response
    end
  end
end
