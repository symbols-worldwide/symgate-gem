require_relative '../spec_helper.rb'

require 'symgate/auth/client'

RSpec.describe(Symgate::Auth::Client) do
  def account_key_client
    account_key_client_of_type Symgate::Auth::Client
  end

  def user_password_client(user, password)
    user_password_client_of_type(Symgate::Auth::Client, user, password)
  end

  def user_token_client(user, token)
    user_token_client_of_type(Symgate::Auth::Client, user, token)
  end

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

    it 'allows the creation of groups with accents in their names' do
      client = account_key_client

      expect { client.create_group('föö') }.not_to raise_error
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

    it 'allows the removal of groups with accents in their names' do
      client = account_key_client

      expect { client.create_group('föö') }.not_to raise_error
      expect(client.enumerate_groups).to match_array(['föö'])
      expect { client.destroy_group('föö') }.not_to raise_error
      expect(client.enumerate_groups).to match_array([])
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
      expect(client.enumerate_users('foo')).to match_array(users)
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

    it 'allows the creation of users with accents in their names' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'föö/böö')

      expect { client.create_group('föö') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect(client.enumerate_users('föö')).to eq([user])
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

  describe '#move_user' do
    # TODO: Bug in upstream. See SOS-204
    # it 'raises an error if the user does not exist' do
    #   client = account_key_client
    #
    #   expect { client.create_group('foo') }.not_to raise_error
    #   expect { client.create_group('bar') }.not_to raise_error
    #   expect { client.move_user('foo/baz', 'bar/baz') }.to raise_error(Symgate::Error)
    # end

    it 'raises an error if the destination group does not exist' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/baz')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect { client.move_user('foo/baz', 'bar/baz') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the destination user already exists' do
      client = account_key_client
      users = [
        Symgate::Auth::User.new(user_id: 'foo/baz'),
        Symgate::Auth::User.new(user_id: 'bar/baz')
      ]

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_group('bar') }.not_to raise_error
      users.each { |u| expect { client.create_user(u, 'asdf1234') }.not_to raise_error }
      expect { client.move_user('foo/baz', 'bar/baz') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the source and destination groups are the same' do
      client = account_key_client
      users = [
        Symgate::Auth::User.new(user_id: 'foo/bar'),
        Symgate::Auth::User.new(user_id: 'foo/baz')
      ]

      expect { client.create_group('foo') }.not_to raise_error
      users.each { |u| expect { client.create_user(u, 'asdf1234') }.not_to raise_error }
      expect { client.move_user('foo/bar', 'foo/baz') }.to raise_error(Symgate::Error)
    end

    it 'moves a user from one group to another' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/baz')
      target_user = Symgate::Auth::User.new(user_id: 'bar/baz')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_group('bar') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error
      expect { client.move_user('foo/baz', 'bar/baz') }.not_to raise_error
      expect(client.enumerate_users('foo')).to eq([])
      expect(client.enumerate_users('bar')).to eq([target_user])
    end
  end

  describe '#set_user_password' do
    it 'raises an error if the user does not exist' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.set_user_password('foo/bar', 'asdf1234') }.to raise_error(Symgate::Error)
    end

    it 'sets the password' do
      client = account_key_client
      user_client = user_password_client('foo/bar', 'asdf1235')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error

      expect { user_client.authenticate }.to raise_error(Symgate::Error)

      expect { client.set_user_password('foo/bar', 'asdf1235') }.not_to raise_error
      expect { user_client.authenticate }.not_to raise_error
    end
  end

  describe '#destroy_user' do
    it 'raises an error if the user does not exist' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.destroy_user('foo/bar') }.to raise_error(Symgate::Error)
    end

    it 'destroys the user' do
      client = account_key_client
      user = Symgate::Auth::User.new(user_id: 'foo/bar')

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(user, 'asdf1234') }.not_to raise_error

      expect(client.enumerate_users('foo')).to eq([user])

      expect { client.destroy_user('foo/bar') }.not_to raise_error

      expect(client.enumerate_users('foo')).to eq([])
    end
  end

  describe '#authenticate' do
    it 'raises an error if the user does not exist' do
      admin_client = account_key_client
      expect { admin_client.create_group('foo') }.not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.authenticate }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the password is incorrect' do
      admin_client = account_key_client
      expect { admin_client.create_group('foo') }.not_to raise_error
      expect { admin_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error

      client = user_password_client('foo/bar', 'asdf1235')
      expect { client.authenticate }.to raise_error(Symgate::Error)
    end

    it 'authenticates and returns a token with normal auth' do
      admin_client = account_key_client
      expect { admin_client.create_group('foo') }.not_to raise_error
      expect { admin_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.authenticate }.not_to raise_error
      expect(client.authenticate).to be_a(String)
      expect(client.authenticate).not_to eq('')
    end

    it 'authenticates and returns a token with impersonation using an account/key' do
      client = account_key_client
      expect { client.create_group('foo') }.not_to raise_error
      expect { client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error

      expect { client.authenticate('foo/bar') }.not_to raise_error
      expect(client.authenticate('foo/bar')).to be_a(String)
      expect(client.authenticate('foo/bar')).not_to eq('')
    end

    it 'raises an error when requesting impersonation as a normal user' do
      admin_client = account_key_client
      expect { admin_client.create_group('foo') }.not_to raise_error
      expect { admin_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error
      expect { admin_client.create_user(Symgate::Auth::User.new(user_id: 'foo/baz'), 'asdf1234') }
        .not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.authenticate('foo/baz') }.to raise_error(Symgate::Error)
    end

    # TODO: currently a bug in upstream, see SOS-206
    # it 'raises an error when trying to authenticate with an account/key and no impersonation' do
    #   client = account_key_client
    #   expect { client.create_group('foo') }.not_to raise_error
    #   expect { client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
    #     .not_to raise_error
    #
    #   expect { client.authenticate }.to raise_error(Symgate::Error)
    # end

    it 'raises an error when impersonating a user that does not exist' do
      client = account_key_client
      expect { client.create_group('foo') }.not_to raise_error

      expect { client.authenticate('foo/bar') }.to raise_error(Symgate::Error)
    end

    it 'authenticates with a correct token' do
      admin_client = account_key_client
      expect { admin_client.create_group('foo') }.not_to raise_error
      expect { admin_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      token = nil
      expect { token = client.authenticate }.not_to raise_error

      token_client = user_token_client('foo/bar', token)
      expect { token_client.authenticate }.not_to raise_error
    end

    it 'raises an error when authenticating with an invalid token' do
      admin_client = account_key_client
      expect { admin_client.create_group('foo') }.not_to raise_error
      expect { admin_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234') }
        .not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.authenticate }.not_to raise_error

      token_client = user_token_client('foo/bar', 'gibberish')
      expect { token_client.authenticate }.to raise_error(Symgate::Error)
    end
  end

  describe '#enumerate_group_languages' do
    it 'raises an error when passed a non-existent group' do
      client = account_key_client

      expect { client.enumerate_group_languages('foo') }.to raise_error(Symgate::Error)
    end

    it 'returns an empty array when there are no group languages' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.enumerate_group_languages('foo') }.not_to raise_error
      expect(client.enumerate_group_languages('foo')).to eq([])
    end

    it 'returns an array with one item when there is one group language' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.add_group_language('foo', 'English_UK') }.not_to raise_error
      expect { client.enumerate_group_languages('foo') }.not_to raise_error
      expect(client.enumerate_group_languages('foo')).to eq(['English_UK'])
    end

    it 'returns an array with multiple languages when there are multiple languages' do
      client = account_key_client
      languages = %w(English_UK Swedish Danish)

      expect { client.create_group('foo') }.not_to raise_error
      languages.each { |l| expect { client.add_group_language('foo', l) }.not_to raise_error }
      expect { client.enumerate_group_languages('foo') }.not_to raise_error
      expect(client.enumerate_group_languages('foo')).to match_array(languages)
    end
  end

  describe '#add_group_language' do
    it 'raises an error if the group does not exist' do
      client = account_key_client

      expect { client.add_group_language('foo', 'English_UK') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the language is invalid' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.add_group_language('foo', 'bar') }.to raise_error(Symgate::Error)
    end

    it 'adds a language to a group' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect(client.enumerate_group_languages('foo')).to eq([])
      expect { client.add_group_language('foo', 'English_UK') }.not_to raise_error
      expect { client.enumerate_group_languages('foo') }.not_to raise_error
      expect(client.enumerate_group_languages('foo')).to eq(['English_UK'])
    end
  end

  describe '#remove_group_language' do
    it 'raises an error if the group does not exist' do
      client = account_key_client

      expect { client.remove_group_language('foo', 'English_UK') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the language is invalid' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.remove_group_language('foo', 'bar') }.to raise_error(Symgate::Error)
    end

    it 'returns NotExist if the group and language are valid, but the language is not assigned' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      r = nil
      expect { r = client.remove_group_language('foo', 'English_UK') }.not_to raise_error
      expect(r).to eq('NotExist')
    end

    it 'returns OK and removes the language if the group has the language assigned' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.add_group_language('foo', 'English_UK') }.not_to raise_error

      r = nil
      expect { r = client.remove_group_language('foo', 'English_UK') }.not_to raise_error
      expect(r).to eq('OK')
    end
  end

  describe '#query_group_language' do
    it 'raises an error if the group does not exist' do
      client = account_key_client

      expect { client.query_group_language('foo', 'English_UK') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the language is invalid' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.query_group_language('foo', 'bar') }.to raise_error(Symgate::Error)
    end

    it 'returns false if the language is not assigned' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.query_group_language('foo', 'English_UK') }.not_to raise_error
      expect(client.query_group_language('foo', 'English_UK')).to eq(false)
    end

    it 'returns true if the language is assigned' do
      client = account_key_client

      expect { client.create_group('foo') }.not_to raise_error
      expect { client.add_group_language('foo', 'English_UK') }.not_to raise_error
      expect { client.query_group_language('foo', 'English_UK') }.not_to raise_error
      expect(client.query_group_language('foo', 'English_UK')).to eq(true)
    end
  end

  describe '#enumerate_languages' do
    before(:each) do
      client = account_key_client
      client.create_group('foo')
      client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234')
    end

    it 'raises an error if called with account/key credentials' do
      client = account_key_client
      expect { client.enumerate_languages }.to raise_error(Symgate::Error)
    end

    it 'returns an empty array when there are no languages assigned' do
      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.enumerate_languages }.not_to raise_error
      expect(client.enumerate_languages).to eq([])
    end

    it 'returns an array with one item when there is one language assigned' do
      admin_client = account_key_client
      expect { admin_client.add_group_language('foo', 'English_UK') }.not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.enumerate_languages }.not_to raise_error
      expect(client.enumerate_languages).to eq(['English_UK'])
    end

    it 'returns an array with multiple items when there are multiple languages assigned' do
      languages = %w(English_UK Danish Swedish)

      admin_client = account_key_client
      languages.each { |l| expect { admin_client.add_group_language('foo', l) }.not_to raise_error }

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.enumerate_languages }.not_to raise_error
      expect(client.enumerate_languages).to match_array(languages)
    end
  end

  describe '#query_language' do
    before(:each) do
      client = account_key_client
      client.create_group('foo')
      client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'asdf1234')
    end

    it 'raises an error if called with account/key credentials' do
      client = account_key_client
      expect { client.query_language('English_UK') }.to raise_error(Symgate::Error)
    end

    it 'raises an error if the language is invalid' do
      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.query_language('baz') }.to raise_error(Symgate::Error)
    end

    it 'returns false if the language is not assigned' do
      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.query_language('English_UK') }.not_to raise_error
      expect(client.query_language('English_UK')).to eq(false)
    end

    it 'returns true if the language is assigned' do
      admin_client = account_key_client
      expect { admin_client.add_group_language('foo', 'English_UK') }.not_to raise_error

      client = user_password_client('foo/bar', 'asdf1234')
      expect { client.query_language('English_UK') }.not_to raise_error
      expect(client.query_language('English_UK')).to eq(true)
    end
  end
end
