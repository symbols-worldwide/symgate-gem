require_relative 'spec_helper.rb'

require 'symgate/auth/client'

RSpec.describe(Symgate::Auth::Client) do
  describe '#enumerate_groups' do
    it 'returns an empty array if there are no groups' do
      client = Symgate::Auth::Client.new(account: 'integration',
                                         key: 'x',
                                         endpoint: 'http://localhost:11122/symbolisation')
      expect(client.enumerate_groups).to match_array([])
    end
  end
end
