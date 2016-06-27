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
end
