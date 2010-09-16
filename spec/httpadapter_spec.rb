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

require 'httpadapter'

class StubAdapter
  def to_ary
    return ['GET', '/', [], [""]]
  end

  def self.from_ary(array)
    return Object.new
  end

  def self.transmit(request, connection=nil)
    return [200, [], ['']]
  end
end

class BogusAdapter
  def initialize(request)
  end
end

describe HTTPAdapter, 'when attempting to specialize a request' do
  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(42, StubAdapter)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request([42], StubAdapter)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        [42, 42, 42, 42], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', 42, [], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', 42, ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [42], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [[42, 'value']], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [['X', 42]], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [], 42], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [], ''], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid adapter' do
    (lambda do
      HTTPAdapter.specialize_request(
        ['GET', '/', [], ['']], Object
      )
    end).should raise_error(TypeError)
  end
end

describe HTTPAdapter, 'when attempting to adapt a request' do
  it 'should raise an error for converting from an invalid adapter' do
    (lambda do
      HTTPAdapter.adapt_request(
        Object.new, BogusAdapter
      )
    end).should raise_error(TypeError)
  end
end

describe HTTPAdapter, 'when attempting to specialize a response' do
  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(42, StubAdapter)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response([42], StubAdapter)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [42, 42, 42], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [Object.new, [], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        ['', 42, ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [42], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [[42, 'value']], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [['X', 42]], ['']], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [], 42], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid tuple' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [], ''], StubAdapter
      )
    end).should raise_error(TypeError)
  end

  it 'should raise an error for converting from an invalid adapter' do
    (lambda do
      HTTPAdapter.specialize_response(
        [200, [], ['']], Object
      )
    end).should raise_error(TypeError)
  end
end

describe HTTPAdapter, 'when attempting to adapt a response' do
  it 'should raise an error for converting from an invalid adapter' do
    (lambda do
      HTTPAdapter.adapt_response(
        Object.new, BogusAdapter
      )
    end).should raise_error(TypeError)
  end
end

describe HTTPAdapter, 'when attempting to transmit a request' do
  it 'should raise an error for invalid request objects' do
    (lambda do
      HTTPAdapter.transmit(42, StubAdapter)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for invalid adapter objects' do
    (lambda do
      HTTPAdapter.transmit(['GET', '/', [], ['']], BogusAdapter)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for invalid connection objects' do
    (lambda do
      HTTPAdapter.transmit(['GET', '/', [], ['']], StubAdapter, 42)
    end).should raise_error(TypeError)
  end
end
