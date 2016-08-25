require 'rspec'
require 'savon/mock/spec_helper'

RSpec.configure do |config|
  include Savon::SpecHelper

  config.before(:each) do
    savon.mock!
  end

  config.after(:each) do
    savon.unmock!
  end
end

def account_key_creds(account, key)
  { 'auth:account': account, 'auth:key': key }
end

def user_password_creds(account, user, password)
  { 'auth:account': account,
    'auth:user': { 'auth:id': user,
                   'auth:password': password } }
end
