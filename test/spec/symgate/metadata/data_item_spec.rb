require_relative '../../spec_helper.rb'

require 'symgate/metadata/data_item'

RSpec.describe(Symgate::Metadata::DataItem) do
  it 'allows access to key, value and scope' do
    d = Symgate::Metadata::DataItem.new
    d.key = 'key'
    d.value = 'value'
    d.scope = 'scope'

    expect(d.key).to eq('key')
    expect(d.value).to eq('value')
    expect(d.scope).to eq('scope')
  end

  it 'allows construction from a hash' do
    d = Symgate::Metadata::DataItem.new(key: 'key',
                                        value: 'value',
                                        scope: 'scope')

    expect(d.key).to eq('key')
    expect(d.value).to eq('value')
    expect(d.scope).to eq('scope')
  end

  it 'allows comparison with another DataItem' do
    d = Symgate::Metadata::DataItem.new(key: 'key',
                                        value: 'value',
                                        scope: 'scope')

    d2 = Symgate::Metadata::DataItem.new(key: 'monkey',
                                         value: 'banana',
                                         scope: 'teapot')

    expect(d == d2).to be_falsey

    d2.key = 'key'
    expect(d == d2).to be_falsey

    d2.value = 'value'
    expect(d == d2).to be_falsey

    d2.scope = 'scope'
    expect(d == d2).to be_truthy
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Metadata::DataItem.new(teapot: false) }.to raise_error(Symgate::Error)
  end
end
