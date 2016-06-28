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
end
