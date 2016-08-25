require_relative '../../spec_helper.rb'

require 'symgate/auth/client'

RSpec.describe(Symgate::Auth::Client) do
  describe '#enumerate_groups' do
    it 'returns an empty array if there are no groups' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_empty.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_groups).to match_array([])
    end

    it 'returns an array with one item if there is one group' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_one.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_groups).to match_array(%w(one))
    end

    it 'returns an array with two items if there are two groups' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_two.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_groups).to match_array(%w(one two))
    end
  end

  describe '#create_group' do
    it 'returns a valid response when creating a group' do
      savon.expects(:create_group)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/create_group.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.create_group('baz') }.not_to raise_error
    end
  end

  describe '#destroy_group' do
    it 'returns a valid response when destroying a group' do
      savon.expects(:destroy_group)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/destroy_group.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.destroy_group('baz') }.not_to raise_error
    end
  end

  describe '#rename_group' do
    it 'returns a valid response when destroying a group' do
      savon.expects(:rename_group)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            old_groupid: 'baz',
                            new_groupid: 'turlingdrome' })
           .returns(File.read('test/spec/fixtures/xml/rename_group.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.rename_group('baz', 'turlingdrome') }.not_to raise_error
    end
  end

  describe '#enumerate_users' do
    it 'returns an empty array if there are no users' do
      savon.expects(:enumerate_users)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/enumerate_users_empty.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_users('baz')).to match_array([])
    end

    it 'returns an array with a single user if there is one user' do
      savon.expects(:enumerate_users)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/enumerate_users_one.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_users('baz'))
        .to match_array([Symgate::Auth::User.new(user_id: 'boris')])
    end

    it 'returns an array with a two users if there are two users' do
      savon.expects(:enumerate_users)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/enumerate_users_two.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_users('baz'))
        .to match_array([
                          Symgate::Auth::User.new(user_id: 'boris'),
                          Symgate::Auth::User.new(user_id: 'farage', is_group_admin: true)
                        ])
    end
  end

  describe '#create_user' do
    it 'creates a user' do
      savon.expects(:create_user)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            'auth:user': '',
                            attributes!: { 'auth:user': { id: 'baz' } },
                            password: 'frob' })
           .returns(File.read('test/spec/fixtures/xml/create_user.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      user = Symgate::Auth::User.new(user_id: 'baz')
      expect { client.create_user(user, 'frob') }.not_to raise_error
    end
  end

  describe '#update_user' do
    it 'updates a user' do
      savon.expects(:update_user)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            'auth:user': '',
                            attributes!: { 'auth:user': { id: 'baz', isGroupAdmin: true } } })
           .returns(File.read('test/spec/fixtures/xml/update_user.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      user = Symgate::Auth::User.new(user_id: 'baz', is_group_admin: true)
      expect { client.update_user(user) }.not_to raise_error
    end
  end

  describe '#rename_user' do
    it 'renames a user' do
      savon.expects(:rename_user)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            old_user_id: 'group/baz',
                            new_user_id: 'group/frob' })
           .returns(File.read('test/spec/fixtures/xml/rename_user.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.rename_user('group/baz', 'group/frob') }.not_to raise_error
    end
  end

  describe '#move_user' do
    it 'moves a user' do
      savon.expects(:move_user)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            old_user_id: 'group/baz',
                            new_user_id: 'frob/baz' })
           .returns(File.read('test/spec/fixtures/xml/rename_user.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.move_user('group/baz', 'frob/baz') }.not_to raise_error
    end
  end

  describe '#set_user_password' do
    it 'sets the user\'s password' do
      savon.expects(:set_user_password)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            userid: 'group/baz',
                            password: 'frob' })
           .returns(File.read('test/spec/fixtures/xml/destroy_user.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.set_user_password('group/baz', 'frob') }.not_to raise_error
    end
  end

  describe '#destroy_user' do
    it 'destroys the user' do
      savon.expects(:destroy_user)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            userid: 'group/baz' })
           .returns(File.read('test/spec/fixtures/xml/destroy_user.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.destroy_user('group/baz') }.not_to raise_error
    end
  end

  describe '#authenticate' do
    it 'authenticates and returns a token with normal auth' do
      savon.expects(:authenticate)
           .with(message: { 'auth:creds': user_password_creds('foo', 'group/baz', 'frob') })
           .returns(File.read('test/spec/fixtures/xml/authenticate.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', user: 'group/baz', password: 'frob')
      token = nil
      expect { token = client.authenticate }.not_to raise_error
      expect(token).to eq('bananana')
    end

    it 'authenticates and returns a token with impersonation' do
      savon.expects(:authenticate)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            userid: 'group/baz' })
           .returns(File.read('test/spec/fixtures/xml/authenticate.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      token = nil
      expect { token = client.authenticate('group/baz') }.not_to raise_error
      expect(token).to eq('bananana')
    end
  end

  describe '#add_group_language' do
    it 'successfully adds a new group language' do
      savon.expects(:add_group_language)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz',
                            language: 'Swedish' })
           .returns(File.read('test/spec/fixtures/xml/add_group_language.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      response = nil
      expect { response = client.add_group_language('baz', 'Swedish') }.not_to raise_error
      expect(response).to eq('OK')
    end

    it 'returns Exists if a language already exists' do
      savon.expects(:add_group_language)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz',
                            language: 'English_UK' })
           .returns(File.read('test/spec/fixtures/xml/add_group_language_exists.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      response = nil
      expect { response = client.add_group_language('baz', 'English_UK') }.not_to raise_error
      expect(response).to eq('Exists')
    end
  end

  describe '#remove_group_language' do
    it 'successfully removes the language from the group' do
      savon.expects(:remove_group_language)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz',
                            language: 'English_UK' })
           .returns(File.read('test/spec/fixtures/xml/remove_group_language.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      response = nil
      expect { response = client.remove_group_language('baz', 'English_UK') }.not_to raise_error
      expect(response).to eq('OK')
    end

    it 'returns NotExist if a language is not present' do
      savon.expects(:remove_group_language)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz',
                            language: 'Swedish' })
           .returns(File.read('test/spec/fixtures/xml/remove_group_language_not_exist.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      response = nil
      expect { response = client.remove_group_language('baz', 'Swedish') }.not_to raise_error
      expect(response).to eq('NotExist')
    end
  end

  describe '#enumerate_group_languages' do
    it 'returns an empty array when there are no languages' do
      savon.expects(:enumerate_group_languages)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/enumerate_group_languages_empty.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_group_languages('baz')).to match_array([])
    end

    it 'returns an empty array when there are no languages' do
      savon.expects(:enumerate_group_languages)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/enumerate_group_languages_one.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_group_languages('baz')).to match_array(['English_UK'])
    end

    it 'returns an array containing two items when there are two languages' do
      savon.expects(:enumerate_group_languages)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz' })
           .returns(File.read('test/spec/fixtures/xml/enumerate_group_languages_two.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_group_languages('baz')).to match_array(%w(English_UK Swedish))
    end
  end

  describe '#query_group_language' do
    it 'returns true if the language is present' do
      savon.expects(:query_group_language)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz',
                            language: 'English_UK' })
           .returns(File.read('test/spec/fixtures/xml/query_group_language_true.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.query_group_language('baz', 'English_UK')).to be_truthy
    end

    it 'returns false if the language is not present' do
      savon.expects(:query_group_language)
           .with(message: { 'auth:creds': account_key_creds('foo', 'bar'),
                            groupid: 'baz',
                            language: 'Swedish' })
           .returns(File.read('test/spec/fixtures/xml/query_group_language_false.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.query_group_language('baz', 'Swedish')).to be_falsey
    end
  end

  describe '#enumerate_languages' do
    it 'returns an empty array when there are no languages' do
      savon.expects(:enumerate_languages)
           .with(message: { 'auth:creds': user_password_creds('foo', 'group/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_languages_empty.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', user: 'group/bar', password: 'baz')
      expect(client.enumerate_languages).to match_array([])
    end

    it 'returns an empty array when there are no languages' do
      savon.expects(:enumerate_languages)
           .with(message: { 'auth:creds': user_password_creds('foo', 'group/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_languages_one.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', user: 'group/bar', password: 'baz')
      expect(client.enumerate_languages).to match_array(['English_UK'])
    end

    it 'returns an array containing two items when there are two languages' do
      savon.expects(:enumerate_languages)
           .with(message: { 'auth:creds': user_password_creds('foo', 'group/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_languages_two.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', user: 'group/bar', password: 'baz')
      expect(client.enumerate_languages).to match_array(%w(English_UK Swedish))
    end
  end

  describe '#query_language' do
    it 'returns true if the language is present' do
      savon.expects(:query_language)
           .with(message: { 'auth:creds': user_password_creds('foo', 'group/bar', 'baz'),
                            language: 'English_UK' })
           .returns(File.read('test/spec/fixtures/xml/query_language_true.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', user: 'group/bar', password: 'baz')
      expect(client.query_language('English_UK')).to be_truthy
    end

    it 'returns false if the language is not present' do
      savon.expects(:query_language)
           .with(message: { 'auth:creds': user_password_creds('foo', 'group/bar', 'baz'),
                            language: 'Swedish' })
           .returns(File.read('test/spec/fixtures/xml/query_language_false.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', user: 'group/bar', password: 'baz')
      expect(client.query_language('Swedish')).to be_falsey
    end
  end
end
