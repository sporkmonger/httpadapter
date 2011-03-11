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

shared_examples_for 'adapter type-checking example' do
  before do
    @request = ['GET', '/', [], ['']]
    @response = [200, [], ['']]
  end

  describe 'when attempting to specialize a request' do
    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(42)
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request([42])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request([42, 42, 42, 42])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(['GET', 42, [], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(['GET', '/', 42, ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(['GET', '/', [42], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(['GET', '/', [[42, 'value']], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(['GET', '/', [['X', 42]], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_request(['GET', '/', [], 42])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        # Note that the body value here should be [''], not ''.
        @adapter.specialize_request(['GET', '/', [], ''])
      end).should raise_error(TypeError)
    end
  end

  describe 'when attempting to specialize a response' do
    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response(42)
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([42])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([42, 42, 42])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([Object.new, [], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response(['', 42, ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([200, [42], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([200, [[42, 'value']], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([200, [['X', 42]], ['']])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        @adapter.specialize_response([200, [], 42])
      end).should raise_error(TypeError)
    end

    it 'should raise an error for converting from an invalid tuple' do
      (lambda do
        # Note that the body value here should be [''], not ''.
        @adapter.specialize_response([200, [], ''])
      end).should raise_error(TypeError)
    end
  end

  it 'should raise an error for invalid adapt request calls' do
    (lambda do
      @adapter.adapt_request(42)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for invalid adapt response calls' do
    (lambda do
      @adapter.adapt_response(42)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for invalid transmission calls' do
    (lambda do
      @adapter.transmit(42)
    end).should raise_error(TypeError)
  end

  it 'should raise an error for invalid transmission calls' do
    (lambda do
      @adapter.transmit(@request, 42)
    end).should raise_error(TypeError)
  end
end
