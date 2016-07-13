require_relative '../spec_helper.rb'

require 'symgate/auth/client'

def account_key_client
  Symgate::Auth::Client.new(account: 'integration',
                            key: 'x',
                            endpoint: 'http://localhost:11122/',
                            savon_opts: savon_opts)
end

RSpec.describe(Symgate::Auth::Client) do
  describe '#enumerate_groups' do
    it 'returns an empty array if there are no groups' do
      client = account_key_client

      expect(client.enumerate_groups).to match_array([])
    end

    it 'returns an array with one element if there is a single group' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect(client.enumerate_groups).to match_array(['foo'])
    end

    it 'returns an array with multiple element if there are multiple groups' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_group('bar') }.not_to raise_error
      expect { client.create_group('baz') }.not_to raise_error

      expect(client.enumerate_groups).to match_array(%w(foo bar baz))
    end
  end

  describe '#create_group' do
    it 'returns a valid response when creating a group' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
    end

    it 'returns an error if passed an invalid group id' do
      client = account_key_client

      expect { client.create_group('foo/bar') }.to raise_error(Symgate::Error)
    end

    it 'returns an error if passed an duplicate group id' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_group('foo') }.to raise_error(Symgate::Error)
    end
  end

  describe '#destroy_group' do
    it 'destroys an existing group' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect(client.enumerate_groups).to match_array(['foo'])
      expect { client.destroy_group('foo') }.not_to raise_error
      expect(client.enumerate_groups).to match_array([])
    end

    it 'raises an error if the group does not exist' do
      client = account_key_client

      expect { client.destroy_group('foo') }.to raise_error(Symgate::Error)
    end
  end

  describe '#rename_group' do
    it 'renames an existing group' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.rename_group('foo', 'bar') }.not_to raise_error
      expect(client.enumerate_groups).to match_array(['bar'])
    end

    # currently a bug in upstream, see SOS-200
    # it 'raises an error if the group does not exist' do
    #   client = account_key_client
    #
    #   expect { client.rename_group('foo', 'bar') }.to raise_error
    # end

    it 'raises an error if the target group name is invalid' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.rename_group('foo', 'bar/baz') }.to raise_error(Symgate::Error)
    end
  end
end
