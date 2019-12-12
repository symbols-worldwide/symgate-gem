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
    u = Symgate::Auth::User.new(user_id: test_user_details[:user], is_group_admin: true)

    expect(u.user_id).to eq(test_user_details[:user])
    expect(u.is_group_admin).to eq(true)
  end

  it 'allows comparison with another User' do
    u = Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true)
    u2 = u.dup

    check_comparison_operator_for_member(u, u2, :user_id, 'baz/qux', 'foo/bar')
    check_comparison_operator_for_member(u, u2, :is_group_admin, false, true)
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Auth::User.new(teapot: false) }.to raise_error(Symgate::Error)
  end

  it 'generates a string summary of the object' do
    u = Symgate::Auth::User.new(user_id: 'foo/bar')
    expect(u.to_s).to be_a(String)
    expect(u.to_s).to include('foo/bar')
    expect(u.to_s).not_to include('admin')

    u.is_group_admin = true
    expect(u.to_s).to include('admin')
  end
end
