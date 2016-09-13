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
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User')
        ]
      )
    end

    it 'returns an array of two DataItems if there are two items' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('baz', 'qux', 'User') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User'),
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'User')
        ]
      )
    end

    it 'returns results limited by scope when a scope is passed' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('baz', 'qux', 'Group') }.not_to raise_error
      expect(client.get_metadata(scope: 'Group')).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'Group')
        ]
      )
    end

    it 'returns results limited by key when a key is passed' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('baz', 'qux', 'Group') }.not_to raise_error
      expect(client.get_metadata(key: 'baz')).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'Group')
        ]
      )
    end

    it 'returns results limited by multiple keys when multiple keys are passed' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('baz', 'qux', 'Group') }.not_to raise_error
      expect { create_data_item('garply', 'thud', 'Group') }.not_to raise_error
      expect(client.get_metadata(keys: %w(foo baz))).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User'),
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'Group')
        ]
      )
    end

    it 'raises an error if supplied an invalid scope' do
      expect { client.get_metadata(scope: 'Teapot') }.to raise_error(Symgate::Error)
    end
  end

  describe '#set_metadata' do
    it 'allows a user to set a user-level permission' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User')
        ]
      )
    end

    it 'allows a group admin user to set a group-level permission' do
      expect { create_data_item('foo', 'bar', 'Group') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Group')
        ]
      )
    end

    it 'does not allow a non-admin user to set a group-level permission' do
      expect do
        non_admin_client.set_metadata(
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Group')
        )
      end.to raise_error(Symgate::Error)
    end

    it 'disallows setting of account-level permissions for users' do
      expect { create_data_item('foo', 'bar', 'Account') }.to raise_error(Symgate::Error)
    end

    it 'allows setting of account-level permissions with an account/key' do
      expect do
        account_key_client_of_type(Symgate::Metadata::Client).set_metadata(
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        )
      end.not_to raise_error

      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        ]
      )
    end

    it 'raises an error when setting of user- and group-level permissions with an account/key' do
      expect do
        account_key_client_of_type(Symgate::Metadata::Client).set_metadata(
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Group')
        )
      end.to raise_error(Symgate::Error)

      expect do
        account_key_client_of_type(Symgate::Metadata::Client).set_metadata(
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User')
        )
      end.to raise_error(Symgate::Error)
    end

    it 'overwrites data with the same key and scope when passed one which already exists' do
      expect { create_data_item('foo', 'bar', 'Group') }.not_to raise_error
      expect { create_data_item('foo', 'baz', 'Group') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'baz', scope: 'Group')
        ]
      )
    end

    it 'creates separate data items for different scopes with the same key' do
      expect { create_data_item('foo', 'bar', 'Group') }.not_to raise_error
      expect { create_data_item('foo', 'baz', 'User') }.not_to raise_error
      expect(client.get_metadata(scope: 'Group')).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Group')
        ]
      )
      expect(client.get_metadata(scope: 'User')).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'baz', scope: 'User')
        ]
      )
    end
  end

  describe '#destroy_metadata' do
    it 'raises an error with an invalid scope' do
      expect { client.destroy_metadata('Teapot', 'foo') }.to raise_error(Symgate::Error)
    end

    it 'deletes user metadata for users when passed a key' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('baz', 'qux', 'User') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User'),
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'User')
        ]
      )

      expect { client.destroy_metadata('User', 'baz') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User')
        ]
      )
    end

    it 'deletes multiple metadata items for users when passed multiple keys' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('baz', 'qux', 'User') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User'),
          Symgate::Metadata::DataItem.new(key: 'baz', value: 'qux', scope: 'User')
        ]
      )

      expect { client.destroy_metadata('User', %w(foo baz)) }.not_to raise_error
      expect(client.get_metadata).to match_array([])
    end

    it 'does not raise an error when deleting an item that does not exist' do
      expect { client.destroy_metadata('User', 'foo') }.not_to raise_error
    end

    it 'only deletes metadata for the specified scope' do
      expect { create_data_item('foo', 'bar', 'User') }.not_to raise_error
      expect { create_data_item('foo', 'baz', 'Group') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'User'),
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'baz', scope: 'Group')
        ]
      )

      expect { client.destroy_metadata('User', 'foo') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'baz', scope: 'Group')
        ]
      )
    end

    it 'allows group admins to delete group-level metadata' do
      expect { create_data_item('foo', 'bar', 'Group') }.not_to raise_error
      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Group')
        ]
      )

      expect { client.destroy_metadata('Group', 'foo') }.not_to raise_error
      expect(client.get_metadata).to match_array([])
    end

    it 'raises an error when non-group-admins attempt to delete group-level metadata' do
      expect { non_admin_client.destroy_metadata('Group', 'foo') }.to raise_error(Symgate::Error)
    end

    it 'raises an error when normal users attempt to delete account-level metadata' do
      expect { client.destroy_metadata('Account', 'foo') }.to raise_error(Symgate::Error)
    end

    it 'allows account-level metadata to be deleted with an account/key' do
      expect do
        account_key_client_of_type(Symgate::Metadata::Client).set_metadata(
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        )
      end.not_to raise_error

      expect(client.get_metadata).to match_array(
        [
          Symgate::Metadata::DataItem.new(key: 'foo', value: 'bar', scope: 'Account')
        ]
      )

      expect do
        account_key_client_of_type(Symgate::Metadata::Client).destroy_metadata('Account', 'foo')
      end.not_to raise_error

      expect(client.get_metadata).to match_array([])
    end

    it 'raises an error when trying to delete user- or group-level metadata with an account/key' do
      expect do
        account_key_client_of_type(Symgate::Metadata::Client).destroy_metadata('Group', 'foo')
      end.to raise_error(Symgate::Error)
      expect do
        account_key_client_of_type(Symgate::Metadata::Client).destroy_metadata('User', 'foo')
      end.to raise_error(Symgate::Error)
    end
  end
end
