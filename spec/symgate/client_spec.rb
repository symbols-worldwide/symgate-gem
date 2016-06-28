require_relative '../spec_helper.rb'

require 'symgate/client'

RSpec.describe(Symgate::Client) do
  describe '#initialize' do
    it 'throws a Symgate error when called with no parameters' do
      expect { Symgate::Client.new }.to raise_error(
        Symgate::Error, 'No account specified'
      )
    end

    it 'throws a Symgate error when called with an account, but no key or user' do
      expect { Symgate::Client.new(account: 'foo') }.to raise_error(
        Symgate::Error, 'No key or user specified'
      )
    end

    it 'throws a Symgate error when called with both a key and user' do
      expect { Symgate::Client.new(account: 'foo', key: 'bar', user: 'baz') }.to raise_error(
        Symgate::Error, 'Both key and user were specified'
      )
    end

    it 'create a valid client if an account and key are specified' do
      client = nil
      expect { client = Symgate::Client.new(account: 'foo', key: 'bar') }.not_to raise_error
      expect(client.savon_client).to be_a(Savon::Client)
    end

    it 'throws a Symgate error when called with a user but no password or token' do
      expect { Symgate::Client.new(account: 'foo', user: 'bar') }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'throws a Symgate error when called with a user with a password and a token' do
      opts = { account: 'foo', user: 'bar', password: 'baz', token: 'nuts' }
      expect { Symgate::Client.new(opts) }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'throws a Symgate error when called with a key and password' do
      opts = { account: 'foo', key: 'bar', password: 'baz' }
      expect { Symgate::Client.new(opts) }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'creates a valid client when called with a user and password' do
      opts = { account: 'foo', user: 'bar', password: 'baz' }
      client = nil
      expect { client = Symgate::Client.new(opts) }.not_to raise_error
      expect(client.savon_client).to be_a(Savon::Client)
    end

    it 'creates a valid client when called with a user and token' do
      opts = { account: 'foo', user: 'bar', token: 'baz' }
      client = nil
      expect { client = Symgate::Client.new(opts) }.not_to raise_error
      expect(client.savon_client).to be_a(Savon::Client)
    end
  end

  describe '#savon_creds' do
    before(:each) do
      Symgate::Client.send(:public, :savon_creds)
    end

    it 'returns a hash' do
      client = Symgate::Client.new(account: 'foo', key: 'bar')
      expect(client.savon_creds).to be_a(Hash)
    end

    it 'adds the account and key to the hash, when specified' do
      client = Symgate::Client.new(account: 'foo', key: 'bar')
      expect(client.savon_creds).to eq('auth:account': 'foo', 'auth:key': 'bar')
    end

    it 'adds the user and password to the hash, when specified' do
      client = Symgate::Client.new(account: 'foo', user: 'bar', password: 'baz')
      expect(client.savon_creds).to eq('auth:account': 'foo', 'auth:user': {
                                         'auth:id': 'bar', 'auth:password': 'baz'
                                       })
    end

    it 'adds the user and token to the hash, when specified' do
      client = Symgate::Client.new(account: 'foo', user: 'bar', token: 'baz')
      expect(client.savon_creds).to eq('auth:account': 'foo', 'auth:user': {
                                         'auth:id': 'bar', 'auth:authtoken': 'baz'
                                       })
    end
  end

  describe '#savon_request' do
    before(:each) do
      Symgate::Client.send(:public, :savon_request)
    end

    it 'fails when an unknown method is called' do
      client = Symgate::Client.new(account: 'foo', key: 'bar')
      expect { client.savon_request(:make_pancakes) }.to raise_error(Savon::UnknownOperationError)
    end

    it 'returns access denied when called with incorrect credentials' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar' })
           .returns(File.read('spec/fixtures/xml/access_denied.xml'))

      client = Symgate::Client.new(account: 'foo', key: 'bar')
      expect { |b| client.savon_request(:enumerate_groups, &b) }.to raise_error do |e|
        expect(e).to be_a(Symgate::Error)
        expect(e.message).to include('Access denied')
      end
    end
  end

  describe '#savon_array' do
    it 'returns an empty array when the hash does not contain the key' do
      expect(Symgate::Client.savon_array({ bar: 'foo' }, :foo)).to match_array([])
    end

    it 'returns an array with one item when the hash item is a non-array' do
      expect(Symgate::Client.savon_array({ foo: 'bar' }, :foo)).to match_array(%w(bar))
    end

    it 'returns an array with multiple items when the hash item is an array' do
      expect(Symgate::Client.savon_array({ foo: %w(bar baz) }, :foo)).to match_array(%w(bar baz))
    end
  end
end
