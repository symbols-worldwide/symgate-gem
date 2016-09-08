require 'rspec'
require 'savon/mock/spec_helper'
require 'simplecov'
require 'simplecov-teamcity-summary'

# rubocop:disable Style/AccessorMethodName

SimpleCov.start do
  minimum_coverage 100

  if ENV['TEAMCITY_VERSION']
    at_exit do
      SimpleCov::Formatter::TeamcitySummaryFormatter.new.format(SimpleCov.result)
      SimpleCov.result.format!
    end
  end
end

RSpec.configure do |config|
  include Savon::SpecHelper

  config.before(:each) do
    savon.mock!
  end

  config.after(:each) do
    begin
      savon.expectations.each(&:verify!)
    ensure
      savon.unmock!
    end
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

def get_kitten(variation = :default)
  File.open(case variation
            when :alternate
              'test/spec/fixtures/kitten_2.jpg'
            else
              'test/spec/fixtures/kitten.jpg'
            end, 'rb').read
end

def get_cfwl
  File.open('test/spec/fixtures/test.cfwl', 'rb').read
end

def check_comparison_operator_for_member(o1, o2, member, bad_value, good_value)
  expect(o1 == o2).to be_a(TrueClass)
  o2.instance_variable_set("@#{member}", bad_value)
  expect(o1 == o2).to be_a(FalseClass)
  o2.instance_variable_set("@#{member}", good_value)
  expect(o1 == o2).to be_a(TrueClass)
end
