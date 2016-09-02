require_relative '../../spec_helper.rb'

require 'symgate/metadata/data_item'

RSpec.describe(Symgate::Auth::User) do
  it 'allows access to user_id and is_group_admin' do
    u = Symgate::Auth::User.new
    u.user_id = 'foo/bar'
    u.is_group_admin = true

    expect(u.user_id).to eq('foo/bar')
    expect(u.is_group_admin).to eq(true)
  end

  it 'allows construction from a hash' do
    u = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)

    expect(u.user_id).to eq('foo/bar')
    expect(u.is_group_admin).to eq(true)
  end

  it 'copies data when using the assignment operator' do
    u = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)

    expect(u.user_id).to eq('foo/bar')
    expect(u.is_group_admin).to eq(true)

    u2 = Symgate::Auth::User.new(user_id: 'bar/baz', is_group_admin: false)
    expect(u2.user_id).to eq('bar/baz')
    expect(u2.is_group_admin).to eq(false)

    u2 = u
    expect(u2.user_id).to eq('foo/bar')
    expect(u2.is_group_admin).to eq(true)
  end

  it 'allows comparison with another User' do
    u = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)
    u2 = Symgate::Auth::User.new(user_id: 'bar/baz', is_group_admin: false)

    expect(u == u2).to be_falsey
    u2.is_group_admin = true
    expect(u == u2).to be_falsey
    u2.user_id = 'foo/bar'
    expect(u == u2).to be_truthy
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Auth::User.new(teapot: false) }.to raise_error(Symgate::Error)
  end
end
