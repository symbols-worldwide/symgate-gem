require_relative '../../spec_helper.rb'

require 'symgate/auth/client'

RSpec.describe(Symgate::Auth::Client) do
  describe '#enumerate_groups' do
    it 'returns an empty array if there are no groups' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar' })
           .returns(File.read('spec/fixtures/xml/enumerate_groups_empty.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_groups).to match_array([])
    end

    it 'returns an array with one item if there is one group' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar' })
           .returns(File.read('spec/fixtures/xml/enumerate_groups_one.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_groups).to match_array(%w(one))
    end

    it 'returns an array with two items if there are two groups' do
      savon.expects(:enumerate_groups)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar' })
           .returns(File.read('spec/fixtures/xml/enumerate_groups_two.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_groups).to match_array(%w(one two))
    end
  end

  describe '#create_group' do
    it 'returns a valid response when creating a group' do
      savon.expects(:create_group)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar', groupid: 'baz' })
           .returns(File.read('spec/fixtures/xml/create_group.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.create_group('baz') }.not_to raise_error
    end
  end

  describe '#destroy_group' do
    it 'returns a valid response when destroying a group' do
      savon.expects(:destroy_group)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar', groupid: 'baz' })
           .returns(File.read('spec/fixtures/xml/destroy_group.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.destroy_group('baz') }.not_to raise_error
    end
  end

  describe '#rename_group' do
    it 'returns a valid response when destroying a group' do
      savon.expects(:rename_group)
           .with(message: { 'auth:account': 'foo',
                            'auth:key': 'bar',
                            old_groupid: 'baz',
                            new_groupid: 'turlingdrome' })
           .returns(File.read('spec/fixtures/xml/rename_group.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect { client.rename_group('baz', 'turlingdrome') }.not_to raise_error
    end
  end

  describe '#enumerate_users' do
    it 'returns an empty array if there are no users' do
      savon.expects(:enumerate_users)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar', groupid: 'baz' })
           .returns(File.read('spec/fixtures/xml/enumerate_users_empty.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_users('baz')).to match_array([])
    end

    it 'returns an array with a single user if there is one user' do
      savon.expects(:enumerate_users)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar', groupid: 'baz' })
           .returns(File.read('spec/fixtures/xml/enumerate_users_one.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_users('baz'))
        .to match_array([Symgate::Auth::User.new(user_id: 'boris')])
    end

    it 'returns an array with a two users if there are two users' do
      savon.expects(:enumerate_users)
           .with(message: { 'auth:account': 'foo', 'auth:key': 'bar', groupid: 'baz' })
           .returns(File.read('spec/fixtures/xml/enumerate_users_two.xml'))

      client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
      expect(client.enumerate_users('baz'))
        .to match_array([
                          Symgate::Auth::User.new(user_id: 'boris'),
                          Symgate::Auth::User.new(user_id: 'farage', is_group_admin: true)
                        ])
    end

    describe '#create_user' do
      it 'creates a user' do
        savon.expects(:create_user)
             .with(message: { 'auth:account': 'foo',
                              'auth:key': 'bar',
                              'auth:user': '',
                              attributes!: { 'auth:user': { id: 'baz' } },
                              password: 'frob' })
             .returns(File.read('spec/fixtures/xml/create_user.xml'))

        client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
        user = Symgate::Auth::User.new(user_id: 'baz')
        expect { client.create_user(user, 'frob') }.not_to raise_error
      end
    end

    describe '#update_user' do
      it 'updates a user' do
        savon.expects(:update_user)
             .with(message: { 'auth:account': 'foo',
                              'auth:key': 'bar',
                              'auth:user': '',
                              attributes!: { 'auth:user': { id: 'baz', isGroupAdmin: true } } })
             .returns(File.read('spec/fixtures/xml/update_user.xml'))

        client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
        user = Symgate::Auth::User.new(user_id: 'baz', is_group_admin: true)
        expect { client.update_user(user) }.not_to raise_error
      end
    end

    describe '#rename_user' do
      it 'renames a user' do
        savon.expects(:rename_user)
             .with(message: { 'auth:account': 'foo',
                              'auth:key': 'bar',
                              old_user_id: 'group/baz',
                              new_user_id: 'group/frob' })
             .returns(File.read('spec/fixtures/xml/rename_user.xml'))

        client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
        expect { client.rename_user('group/baz', 'group/frob') }.not_to raise_error
      end
    end

    describe '#move_user' do
      it 'moves a user' do
        savon.expects(:move_user)
             .with(message: { 'auth:account': 'foo',
                              'auth:key': 'bar',
                              old_user_id: 'group/baz',
                              new_user_id: 'frob/baz' })
             .returns(File.read('spec/fixtures/xml/rename_user.xml'))

        client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
        expect { client.move_user('group/baz', 'frob/baz') }.not_to raise_error
      end
    end

    describe '#set_user_password' do
      it 'sets the user\'s password' do
        savon.expects(:set_user_password)
             .with(message: { 'auth:account': 'foo',
                              'auth:key': 'bar',
                              userid: 'group/baz',
                              password: 'frob' })
             .returns(File.read('spec/fixtures/xml/set_user_password.xml'))

        client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
        expect { client.set_user_password('group/baz', 'frob') }.not_to raise_error
      end
    end

    describe '#destroy_user' do
      it 'destroys the user' do
        savon.expects(:destroy_user)
             .with(message: { 'auth:account': 'foo',
                              'auth:key': 'bar',
                              userid: 'group/baz' })
             .returns(File.read('spec/fixtures/xml/destroy_user.xml'))

        client = Symgate::Auth::Client.new(account: 'foo', key: 'bar')
        expect { client.destroy_user('group/baz') }.not_to raise_error
      end
    end
  end
end
