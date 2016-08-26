require_relative '../spec_helper.rb'

require 'symgate/metadata/client'

RSpec.describe(Symgate::Metadata::Client) do
  def client
    user_password_client_of_type(Symgate::Metadata::Client, 'foo/bar', 'baz')
  end

  before(:each) do
    auth_client = account_key_client_of_type(Symgate::Auth::Client)
    auth_client.create_group('foo')
    auth_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'baz')
  end

  describe '#get_metadata' do
    it 'returns an empty array if there is no metadata' do
      expect(client.get_metadata).to match_array([])
    end
  end
end
