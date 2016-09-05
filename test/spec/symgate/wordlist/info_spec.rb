require_relative '../../spec_helper.rb'

require 'symgate/wordlist/info'

RSpec.describe(Symgate::Wordlist::Info) do
  it 'allows access to all attributes' do
    i = Symgate::Wordlist::Info.new
    dt = DateTime.now

    i.name = 'wordlist'
    i.context = 'User'
    i.uuid = '4c1ef7d0-5357-0134-9ec1-20cf302b46f2'
    i.engine = 'sql'
    i.scope = 'Group'
    i.entry_count = 512
    i.last_change = dt

    expect(i.name).to eq('wordlist')
    expect(i.context).to eq('User')
    expect(i.uuid).to eq('4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
    expect(i.engine).to eq('sql')
    expect(i.scope).to eq('Group')
    expect(i.entry_count).to eq(512)
    expect(i.last_change).to eq(dt)
  end

  it 'allows construction from a hash' do
    dt = DateTime.now
    i = Symgate::Wordlist::Info.new(name: 'wordlist',
                                    context: 'User',
                                    uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2',
                                    engine: 'sql',
                                    scope: 'Group',
                                    entry_count: 512,
                                    last_change: dt)

    expect(i.name).to eq('wordlist')
    expect(i.context).to eq('User')
    expect(i.uuid).to eq('4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
    expect(i.engine).to eq('sql')
    expect(i.scope).to eq('Group')
    expect(i.entry_count).to eq(512)
    expect(i.last_change).to eq(dt)
  end

  it 'allows comparison with another Wordlist Info' do
    dt = DateTime.now
    i = Symgate::Wordlist::Info.new(name: 'wordlist',
                                    context: 'User',
                                    uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2',
                                    engine: 'sql',
                                    scope: 'Group',
                                    entry_count: 512,
                                    last_change: dt)

    i2 = i.dup

    check_comparison_operator_for_member(i, i2, :name, 'Widgit Pictures', 'wordlist')
    check_comparison_operator_for_member(i, i2, :context, 'Group', 'User')
    check_comparison_operator_for_member(i, i2, :uuid,
                                         'f7a23690-534a-0134-9ec1-20cf302b46f2',
                                         '4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
    check_comparison_operator_for_member(i, i2, :engine, 'disk', 'sql')
    check_comparison_operator_for_member(i, i2, :scope, 'User', 'Group')
    check_comparison_operator_for_member(i, i2, :entry_count, 256, 512)
    check_comparison_operator_for_member(i, i2, :last_change, dt - 30, dt)
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Wordlist::Info.new(teapot: false) }.to raise_error(Symgate::Error)
  end

  it 'generates a string summary of the object' do
    i = Symgate::Wordlist::Info.new(name: 'Widgit Pictures',
                                    context: 'User',
                                    uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2',
                                    engine: 'sql',
                                    scope: 'Group',
                                    entry_count: 512,
                                    last_change: DateTime.now)

    expect(i.to_s).to be_a(String)
    expect(i.to_s).to include('Widgit Pictures')
    expect(i.to_s).to include('4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
    expect(i.to_s).to include('512')
  end
end
