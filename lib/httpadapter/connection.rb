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
# 


module HTTPAdapter
  class Connection
    def initialize(host, port, connection, options={})
      if !host.respond_to?(:to_str)
        raise TypeError, "Expected String, got #{host.class}."
      end
      @host = host.to_str
      if port.kind_of?(Symbol) || !port.respond_to?(:to_i)
        raise TypeError, "Expected Integer, got #{port.class}."
      end
      @port = port.to_i
      unless (1..65535) === @port
        raise ArgumentError, "Invalid port number."
      end
      @connection = connection
      @options = options
    end

    def open
      if @options[:open]
        method, args, block = @options[:open]
        method ||= :open
        args ||= []
        return @connection.send(method, *args, &block)
      else
        # No-op
        return nil
      end
    end

    def close
      if @options[:close]
        method, args, block = @options[:close]
        method ||= :close
        args ||= []
        return @connection.send(method, *args, &block)
      else
        # No-op
        return nil
      end
    end

    def join
      if @options[:join]
        method, args, block = @options[:join]
        method ||= :join
        args ||= []
        return @connection.send(method, *args, &block)
      else
        # No-op
        return nil
      end
    end

    attr_reader :host, :port, :connection
  end
end
