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
