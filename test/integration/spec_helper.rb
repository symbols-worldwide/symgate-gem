require 'rspec'
require 'mysql2'
require 'savon'

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
