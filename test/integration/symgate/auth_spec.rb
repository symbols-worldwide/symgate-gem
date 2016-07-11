require_relative '../spec_helper.rb'

require 'symgate/auth/client'

RSpec.describe(Symgate::Auth::Client) do
  describe '#enumerate_groups' do
    it 'returns an empty array if there are no groups' do
      client = Symgate::Auth::Client.new(account: 'integration',
                                         key: 'x',
                                         endpoint: 'http://localhost:11122/',
                                         savon_opts: savon_opts)

      expect(client.enumerate_groups).to match_array([])
    end

    it 'returns an array with one element if there is a single group' do
      client = Symgate::Auth::Client.new(account: 'integration',
                                         key: 'x',
                                         endpoint: 'http://localhost:11122/',
                                         savon_opts: savon_opts)

      expect { client.create_group('foo') }.not_to raise_error
      expect(client.enumerate_groups).to match_array(['foo'])
    end

    it 'returns an array with multiple element if there are multiple groups' do
      client = Symgate::Auth::Client.new(account: 'integration',
                                         key: 'x',
                                         endpoint: 'http://localhost:11122/',
                                         savon_opts: savon_opts)

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_group('bar') }.not_to raise_error
      expect { client.create_group('baz') }.not_to raise_error

      expect(client.enumerate_groups).to match_array(%w(foo bar baz))
    end
  end
end
