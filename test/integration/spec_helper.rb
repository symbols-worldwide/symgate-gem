require 'rspec'
require 'mysql2'
require 'savon'
require 'symgate/wordlist/entry'

# rubocop:disable Naming/AccessorMethodName

def integration_mysql_client
  Mysql2::Client.new(host: '127.0.0.1',
                     port: 33306,
                     username: 'symboliser',
                     password: 'symboliser',
                     database: 'symboliser')
end

def savon_opts
  { log: true, log_level: :debug, pretty_print_xml: true }
end

RSpec.configure do |config|
  config.before(:each) do
    integration_mysql_client.query('DELETE FROM accounts WHERE account_name="integration";')
    integration_mysql_client.query('INSERT INTO accounts (account_name,account_key) '\
                                   'VALUES ("integration","x");')
  end
end

def account_key_client_of_type(client_type)
  client_type.new(account: 'integration',
                  key: 'x',
                  endpoint: 'http://localhost:11122/',
                  savon_opts: savon_opts)
end

def user_password_client_of_type(client_type, user, password)
  client_type.new(account: 'integration',
                  user: user,
                  password: password,
                  endpoint: 'http://localhost:11122/',
                  savon_opts: savon_opts)
end

def user_token_client_of_type(client_type, user, token)
  client_type.new(account: 'integration',
                  user: user,
                  token: token,
                  endpoint: 'http://localhost:11122/',
                  savon_opts: savon_opts)
end

def get_kitten(variation = :default)
  File.open(case variation
            when :alternate
              'test/integration/fixtures/kitten_2.jpg'
            else
              'test/integration/fixtures/kitten.jpg'
            end, 'rb').read
end

def get_cfwl
  File.open('test/integration/fixtures/test.cfwl', 'rb').read
end

def check_comparison_operator_for_member(o1, o2, member, bad_value, good_value)
  expect(o1 == o2).to be_a(TrueClass)
  o2.instance_variable_set("@#{member}", bad_value)
  expect(o1 == o2).to be_a(FalseClass)
  o2.instance_variable_set("@#{member}", good_value)
  expect(o1 == o2).to be_a(TrueClass)
end

def reset_wordlist_entry_times(array, datetime)
  array.map do |entry|
    entry.last_change = datetime
    entry
  end
end

# rubocop:enable Naming/AccessorMethodName
