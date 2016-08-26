require_relative '../spec_helper.rb'

require 'symgate/metadata/client'

RSpec.describe(Symgate::Metadata::Client) do
  def client
    user_password_client_of_type(Symgate::Metadata::Client, 'foo/bar', 'baz')
  end

  def non_admin_client
    user_password_client_of_type(Symgate::Metadata::Client, 'foo/baz', 'qux')
  end

  def create_data_item(key, value, scope)
    client.set_metadata(Symgate::Metadata::DataItem.new(key: key,
                                                        value: value,
                                                        scope: scope))
  end

  before(:each) do
    auth_client = account_key_client_of_type(Symgate::Auth::Client)
    auth_client.create_group('foo')

    [
      [Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true), 'baz'],
      [Symgate::Auth::User.new(user_id: 'foo/baz', is_group_admin: false), 'qux']
    ].each { |u| auth_client.create_user(u[0], u[1]) }
  end

  describe '#get_metadata' do
    it 'returns an empty array if there is no metadata' do
      expect(client.get_metadata).to match_array([])
    end

    it 'returns an array of one DataItem if there is one item' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [Symgate::Metadata::DataItem.new(key: 'foo', 'value': 'bar', scope: 'User')]
      )
    end
  end
end
