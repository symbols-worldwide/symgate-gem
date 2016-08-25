require_relative '../../spec_helper.rb'

require 'symgate/metadata/client'

RSpec.describe(Symgate::Auth::Client) do
  describe '#get_metadata' do
    it 'returns an empty array if there are no items' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/get_metadata_empty.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.get_metadata).to match_array([])
    end

    it 'returns an array of one DataItem if there is one item' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/get_metadata_one.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        ]
      )
    end

    it 'returns an array of multiple DataItems if there are several items' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/get_metadata_two.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account'),
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'User')
        ]
      )
    end

    it 'accepts a scope as an input' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz'),
                            scope: 'Account' })
           .returns(File.read('test/spec/fixtures/xml/get_metadata_one.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.get_metadata(scope: 'Account')).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        ]
      )
    end

    it 'raises an error if an invalid scope is supplied' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz'),
                            scope: 'Teapot' })
           .returns(File.read('test/spec/fixtures/xml/generic_error.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.get_metadata(scope: 'Teapot') }.to raise_error(Symgate::Error)
    end

    it 'accepts an array of keys as an input' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz'),
                            keys: %w(foo baz) })
           .returns(File.read('test/spec/fixtures/xml/get_metadata_two.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.get_metadata(keys: %w(foo baz))).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account'),
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'User')
        ]
      )
    end

    it 'accepts a single key as an input' do
      savon.expects(:get_metadata)
           .with(message: { 'auth:creds': user_password_creds('foo', 'foo/bar', 'baz'),
                            keys: %w(foo) })
           .returns(File.read('test/spec/fixtures/xml/get_metadata_one.xml'))

      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.get_metadata(key: 'foo')).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        ]
      )
    end

    it 'raises an error if "keys" is not an array' do
      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.get_metadata(keys: 'foo') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if "keys" contains non-string items' do
      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.get_metadata(keys: ['foo', 6]) }.to raise_error(Symgate::Error)
    end

    it 'raises an error if "key" is not a string' do
      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.get_metadata(key: nil) }.to raise_error(Symgate::Error)
    end

    it 'raises an error if both "key" and "keys" are supplied' do
      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.get_metadata(key: 'foo', keys: %w(bar baz)) }.to raise_error(Symgate::Error)
    end

    it 'raises an error if an unknown option is supplied' do
      client = Symgate::Metadata::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.get_metadata(kettle: 'black') }.to raise_error(Symgate::Error)
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
