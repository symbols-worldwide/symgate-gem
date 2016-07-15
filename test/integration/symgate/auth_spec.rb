require_relative '../spec_helper.rb'

require 'symgate/auth/client'

def account_key_client
  Symgate::Auth::Client.new(account: 'integration',
                            key: 'x',
                            endpoint: 'http://localhost:11122/',
                            savon_opts: savon_opts)
end

def user_password_client(user, password)
  Symgate::Auth::Client.new(account: 'integration',
                            user: user,
                            password: password,
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

    # TODO: currently a bug in upstream, see SOS-200
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

  describe '#enumerate_users' do
    # TODO: currently a bug in upstream, see SOS-201
    # it 'raises an error for an invalid group' do
    #   client = account_key_client
    #
    #   expect { client.enumerate_users('foo') }.to raise_error(Symgate::Error)
    # end

    it 'returns an empty array if there are no users' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([])
    end

    it 'returns an array with a single user if there is one user' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'password') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])
    end

    it 'returns an array with multiple users if there are multiple users' do
      client = account_key_client
      users = [
        Symgate::Auth::User.new(user_id: 'foo/bar'),
        Symgate::Auth::User.new(user_id: 'foo/baz'),
        Symgate::Auth::User.new(user_id: 'foo/qux', is_group_admin: true)
      ]

      expect { client.create_group('foo') }.not_to raise_error
      users.each { |u| expect { client.create_user(u, 'password') }.not_to raise_error }
      expect(client.enumerate_users('foo')).to eq(users)
    end
  end

  describe '#create_user' do
    it 'should raise an error if the user id does not contain a group' do
      client = account_key_client

      expect { client.create_user(Symgate::Auth::User.new(user_id: 'fnar'), 'asdf1234') }
        .to raise_error(Symgate::Error)
    end

    it 'should raise an error if the user id within the group is invalid' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error

      expect { client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar/baz'), 'asdf1234') }
        .to raise_error(Symgate::Error)
    end

    it 'should raise an error if the group does not exist' do
      client = account_key_client

      expect { client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .to raise_error(Symgate::Error)
    end

    it 'should create a user when called with correct parameters' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar')

      expect { client.create_group('foo') }.not_to raise_error

      expect { client.create_user(user, 'asdf1234') }.not_to raise_error

      expect(client.enumerate_users('foo')).to eq([user])
    end

    it 'should create a group admin user when requested to do so' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])
    end

    it 'should raise an error when called with user credentials' do
      admin_client = account_key_client
      user_client = user_password_client('foo/bar', 'asdf1234')
      admin_user = Symgate::Auth::User.new(user_id: 'foo/bar')
      new_user = Symgate::Auth::User.new(user_id: 'foo/baz')

      expect { admin_client.create_group('foo') }.not_to raise_error
      expect { admin_client.create_user(admin_user, 'asdf1234') }.not_to raise_error
      expect(admin_client.enumerate_users('foo')).to eq([admin_user])

      expect { user_client.create_user(new_user, 'asdf1234') }.to raise_error(Symgate::Error)
    end

    # TODO: Bug in upstream. See SOS-202
    # it 'should raise an error when called with a blank password' do
    #   client = account_key_client
    #   user = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)
    #
    #   expect { client.create_group('foo') }.not_to raise_error
    #   expect { client.create_user(user, '') }.to raise_error(Symgate::Error)
    # end
  end

  describe '#update_user' do
    it 'raises an error when called with a non-existent user' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.update_user(user) }.to raise_error(Symgate::Error)
    end

    it 'removes the is_group_admin setting when requested' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])

      user.is_group_admin = false
      expect { client.update_user(user) }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])
    end

    it 'adds the is_group_admin setting when requested' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: false)

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])

      user.is_group_admin = true
      expect { client.update_user(user) }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])
    end

    it 'does not raise an error or change anything when is_group_admin is left unchanged' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: false)

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])
      expect { client.update_user(user) }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([user])
    end
  end

  describe '#rename_user' do
    # TODO: Bug in upstream. See SOS-203
    # it 'raises an error if the user does not exist' do
    #   client = account_key_client
    #
    #   expect { client.create_group('foo') }.not_to raise_error
    #   expect { client.rename_user('foo/bar', 'foo/baz') }.to raise_error(Symgate::Error)
    # end

    it 'raises a user if the desired username is taken' do
      client = account_key_client
      users = [
        Symgate::Auth::User.new(user_id: 'foo/bar'),
        Symgate::Auth::User.new(user_id: 'foo/baz')
      ]

      expect { client.create_group('foo') }.not_to raise_error
      users.each { |u| expect { client.create_user(u, 'asdf1234') }.not_to raise_error }

      expect { client.rename_user('foo/bar', 'foo/baz') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the target group is different' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error

      expect { client.rename_user('foo/bar', 'baz/qux') }.to raise_error(Symgate::Error)
    end

    it 'renames a user' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar')
      target_user = Symgate::Auth::User.new(user_id: 'foo/baz')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error

      expect { client.rename_user('foo/bar', 'foo/baz') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([target_user])
    end
  end
end
