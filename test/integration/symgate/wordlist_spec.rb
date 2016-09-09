require_relative '../spec_helper.rb'

require 'symgate/wordlist/client'

RSpec.describe(Symgate::Wordlist::Client) do
  def client
    user_password_client_of_type(Symgate::Wordlist::Client, 'foo/bar', 'baz')
  end

  def non_admin_client
    user_password_client_of_type(Symgate::Wordlist::Client, 'foo/baz', 'qux')
  end

  def account_key_client
    account_key_client_of_type(Symgate::Wordlist::Client)
  end

  before(:each) do
    auth_client = account_key_client_of_type(Symgate::Auth::Client)
    auth_client.create_group('foo')

    [
      [Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true), 'baz'],
      [Symgate::Auth::User.new(user_id: 'foo/baz', is_group_admin: false), 'qux']
    ].each { |u| auth_client.create_user(u[0], u[1]) }
  end

  describe '#create_wordlist' do
    it 'allows an admin user to create a user wordlist' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
    end

    it 'allows a non-admin user to create a user wordlist' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
    end

    it 'returns a wordlist info object about the newly-created wordlist' do
      resp = nil

      expect { resp = client.create_wordlist('foo', 'User') }
        .not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('User')
      expect(resp.entry_count).to be_a(Integer)
      expect(resp.entry_count).to eq(0)
      expect(resp.last_change).to be_a(DateTime)
      expect(resp.last_change).to be > DateTime.now - 30
      expect(resp.last_change).to be < DateTime.now
      expect(resp.engine).to eq('sql')
      expect(resp.uuid).to match(/^{[0-9a-f-]{36}}$/)
    end

    it 'allows an admin user to create a topic wordlist' do
      resp = nil

      expect { resp = client.create_wordlist('foo', 'Topic') }
        .not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('Topic')
    end

    # TODO: Disabled. See CL-9949
    # it 'raises an error when a non-admin user creates a topic wordlist' do
    #   expect { non_admin_client.create_wordlist('foo', 'Topic') }
    #     .to raise_error(Symgate::Error)
    # end

    it 'raises an error when trying to create a lexical wordlist' do
      expect { client.create_wordlist('foo', 'Lexical') }
        .to raise_error(Symgate::Error)
    end

    it 'raises an error when trying to create a wordlist with an account/key client' do
      expect { account_key_client.create_wordlist('foo', 'Lexical') }
        .to raise_error(Symgate::Error)

      expect { account_key_client.create_wordlist('foo', 'User') }
        .to raise_error(Symgate::Error)
    end
  end

  describe '#enumerate_wordlists' do
    it 'returns an empty array when there are no wordlists' do
      expect(client.enumerate_wordlists).to match_array([])
    end
  end
end
