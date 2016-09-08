require_relative '../spec_helper.rb'

require 'symgate/wordlist/client'

RSpec.describe(Symgate::Wordlist::Client) do
  def client
    user_password_client_of_type(Symgate::Wordlist::Client, 'foo/bar', 'baz')
  end

  before(:each) do
    auth_client = account_key_client_of_type(Symgate::Auth::Client)
    auth_client.create_group('foo')

    auth_client.create_user(Symgate::Auth::User.new(user_id: 'foo/bar'), 'baz')
  end

  describe '#enumerate_wordlists' do
    it 'returns an empty array when there are no wordlists' do
      expect(client.enumerate_wordlists).to match_array([])
    end
  end
end
