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
require 'httpadapter/connection'
require 'net/http'
require 'addressable/uri'

module HTTPAdapter #:nodoc:
  class NetHTTPRequestAdapter
    METHOD_MAPPING = {
      # RFC 2616
      'OPTIONS' => Net::HTTP::Options,
      'GET' => Net::HTTP::Get,
      'HEAD' => Net::HTTP::Head,
      'POST' => Net::HTTP::Post,
      'PUT' => Net::HTTP::Put,
      'DELETE' => Net::HTTP::Delete,
      'TRACE' => Net::HTTP::Trace,
      # Other standards supported by Net::HTTP
      'COPY' => Net::HTTP::Copy,
      'LOCK' => Net::HTTP::Lock,
      'MKCOL' => Net::HTTP::Mkcol,
      'MOVE' => Net::HTTP::Move,
      'PROPFIND' => Net::HTTP::Propfind,
      'PROPPATCH' => Net::HTTP::Proppatch,
      'UNLOCK' => Net::HTTP::Unlock
    }

    def initialize(request, options={})
      unless request.kind_of?(Net::HTTPRequest)
        raise TypeError, "Expected Net::HTTPRequest, got #{request.class}."
      end
      @request = request
      @uri = Addressable::URI.parse(options[:uri] || request.path || "")
      if !@uri.host && options[:host]
        @uri.host = options[:host]
        if !@uri.scheme && options[:scheme]
          @uri.scheme = options[:scheme]
        elsif !@uri.scheme
          @uri.scheme = 'http'
        end
        if !@uri.port && options[:port]
          @uri.port = options[:port]
        end
        @uri.scheme = @uri.normalized_scheme
        @uri.authority = @uri.normalized_authority
      end
    end

    def to_ary
      method = @request.method.to_s.upcase
      uri = @uri.to_str
      headers = []
      @request.canonical_each do |header, value|
        headers << [header, value]
      end
      body = @request.body || ""
      return [method, uri, headers, [body]]
    end

    def self.from_ary(array)
      method, uri, headers, body = array
      method = method.to_s.upcase
      uri = Addressable::URI.parse(uri)
      request_class = METHOD_MAPPING[method]
      unless request_class
        raise ArgumentError, "Unknown HTTP method: #{method}"
      end
      request = request_class.new(uri.request_uri)
      headers.each do |header, value|
        request[header] = value
        if header.downcase == 'Content-Type'.downcase
          request.content_type = value
        end
      end
      merged_body = ""
      body.each do |chunk|
        merged_body += chunk
      end
      if merged_body.length > 0
        request.body = merged_body
      elsif ['POST', 'PUT'].include?(method)
        request.content_length = 0
      end
      return request
    end

    def self.transmit(request, connection=nil)
      method, uri, headers, body = request
      uri = Addressable::URI.parse(uri)
      net_http_request = self.from_ary([method, uri, headers, body])
      net_http_response = nil
      unless connection
        http = Net::HTTP.new(uri.host, uri.inferred_port)
        if uri.normalized_scheme == 'https'
          require 'net/https'
          http.use_ssl = true
          if http.respond_to?(:enable_post_connection_check=)
            http.enable_post_connection_check = true
          end
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          ca_file = File.expand_path(ENV['CA_FILE'] || '~/.cacert.pem')
          if File.exists?(ca_file)
            http.ca_file = ca_file
          end
          store = OpenSSL::X509::Store.new
          store.set_default_paths
          http.cert_store = store
          context = http.instance_variable_get('@ssl_context')
          if context && context.respond_to?(:tmp_dh_callback) &&
              context.tmp_dh_callback == nil
            context.tmp_dh_callback = lambda do |*args|
              tmp_dh_key_file = File.expand_path(
                ENV['TMP_DH_KEY_FILE'] || '~/.dhparams.pem'
              )
              if File.exists?(tmp_dh_key_file)
                OpenSSL::PKey::DH.new(File.read(tmp_dh_key_file))
              else
                # Slow, fix with `openssl dhparam -out ~/.dhparams.pem 2048`
                OpenSSL::PKey::DH.new(512)
              end
            end
          end
        end
        http.start
        connection = HTTPAdapter::Connection.new(
          uri.host, uri.inferred_port, http,
          :open => [:start, [], nil],
          :close => [:finish, [], nil]
        )
      else
        http = nil
      end
      net_http_response = connection.connection.request(net_http_request)
      if http
        connection.close
      end
      return NetHTTPResponseAdapter.new(net_http_response).to_ary
    end
  end

  class NetHTTPResponseAdapter
    STATUS_MESSAGES = {
      100 => "Continue",
      101 => "Switching Protocols",
      102 => "Processing",

      200 => "OK",
      201 => "Created",
      202 => "Accepted",
      203 => "Non-Authoritative Information",
      204 => "No Content",
      205 => "Reset Content",
      206 => "Partial Content",
      207 => "Multi-Status",
      226 => "IM Used",

      300 => "Multiple Choices",
      301 => "Moved Permanently",
      302 => "Found",
      303 => "See Other",
      304 => "Not Modified",
      305 => "Use Proxy",
      307 => "Temporary Redirect",

      400 => "Bad Request",
      401 => "Unauthorized",
      402 => "Payment Required",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      406 => "Not Acceptable",
      407 => "Proxy Authentication Required",
      408 => "Request Timeout",
      409 => "Conflict",
      410 => "Gone",
      411 => "Length Required",
      412 => "Precondition Failed",
      413 => "Request Entity Too Large",
      414 => "Request-URI Too Long",
      415 => "Unsupported Media Type",
      416 => "Requested Range Not Satisfiable",
      417 => "Expectation Failed",
      422 => "Unprocessable Entity",
      423 => "Locked",
      424 => "Failed Dependency",
      426 => "Upgrade Required",

      500 => "Internal Server Error",
      501 => "Not Implemented",
      502 => "Bad Gateway",
      503 => "Service Unavailable",
      504 => "Gateway Timeout",
      505 => "HTTP Version Not Supported",
      507 => "Insufficient Storage",
      510 => "Not Extended"
    }
    STATUS_MAPPING = Net::HTTPResponse::CODE_TO_OBJ

    def initialize(response)
      unless response.kind_of?(Net::HTTPResponse)
        raise TypeError, "Expected Net::HTTPResponse, got #{response.class}."
      end
      @response = response
    end

    def to_ary
      status = @response.code.to_i
      headers = []
      @response.canonical_each do |header, value|
        headers << [header, value]
      end
      body = @response.body || ""
      return [status, headers, [body]]
    end

    def self.from_ary(array)
      status, headers, body = array
      message = STATUS_MESSAGES[status.to_i]
      response_class = STATUS_MAPPING[status.to_s]
      unless message && response_class
        raise ArgumentError, "Unknown status code: #{status}"
      end
      status = status.to_i
      response = response_class.new('1.1', status.to_s, message)
      headers.each do |header, value|
        response.add_field(header, value)
      end
      merged_body = ""
      body.each do |chunk|
        merged_body += chunk
      end

      # Ugh
      response.instance_variable_set('@read', true)
      response.instance_variable_set('@body', merged_body)

      return response
    end
  end
end
