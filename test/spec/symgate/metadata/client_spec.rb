require_relative '../../spec_helper.rb'

require 'symgate/metadata/client'

RSpec.describe(Symgate::Auth::Client) do
  describe '#get_metadata' do
    it 'returns an empty array if there are no items' do
    end

    it 'returns an array of one DataItem if there is one item' do
    end

    it 'returns an array of multiple DataItems if there are several items' do
    end

    it 'accepts a scope as an input' do
    end

    it 'raises an error if an invalid scope is supplied' do
    end

    it 'accepts an array of keys as an input' do
    end

    it 'accepts a single key as an input' do
    end

    it 'raises an error if "keys" is not an array' do
    end

    it 'raises an error if "keys" contains non-string items' do
    end

    it 'raises an error if "key" is not a string' do
    end

    it 'raises an error if an unknown option is supplied' do
    end
  end

  describe '#set_metadata' do
    it 'raises an error if no metadata items are supplied' do
    end

    it 'accepts a single metadata item' do
    end

    it 'accepts multiple metadata items' do
    end

    it 'raises an error if passed something that isn\'t a metadata item' do
    end
  end

  describe '#destroy_metadata' do
    it 'raises an error if an invalid scope is supplied' do
    end

    it 'raises an error if no keys are supplied' do
    end

    it 'raises an error if supplied a key that isn\'t a string' do
    end

    it 'accepts a valid scope and single key string' do
    end

    it 'accepts a valid scope and multiple key strings' do
    end
  end
end
