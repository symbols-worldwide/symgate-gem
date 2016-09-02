require_relative '../../spec_helper.rb'

require 'symgate/cml/symbol'

RSpec.describe(Symgate::Cml::Symbol) do
  it 'allows access to all symbol attributes' do
    s = Symgate::Cml::Symbol.new

    s.symset = 'symset'
    s.main = 'main'
    s.top_left = 'top_left'
    s.top_right = 'top_right'
    s.bottom_left = 'bottom_left'
    s.bottom_right = 'bottom_right'
    s.full_left = 'full_left'
    s.full_right = 'full_right'
    s.top = 'top'
    s.extra = 'extra'

    expect(s.symset).to eq('symset')
    expect(s.main).to eq('main')
    expect(s.top_left).to eq('top_left')
    expect(s.top_right).to eq('top_right')
    expect(s.bottom_left).to eq('bottom_left')
    expect(s.bottom_right).to eq('bottom_right')
    expect(s.full_left).to eq('full_left')
    expect(s.full_right).to eq('full_right')
    expect(s.top).to eq('top')
    expect(s.extra).to eq('extra')
  end

  it 'allows construction from a hash' do
    s = Symgate::Cml::Symbol.new(symset: 'symset',
                                 main: 'main',
                                 top_left: 'top_left',
                                 top_right: 'top_right',
                                 bottom_left: 'bottom_left',
                                 bottom_right: 'bottom_right',
                                 full_left: 'full_left',
                                 full_right: 'full_right',
                                 top: 'top',
                                 extra: 'extra')

    expect(s.symset).to eq('symset')
    expect(s.main).to eq('main')
    expect(s.top_left).to eq('top_left')
    expect(s.top_right).to eq('top_right')
    expect(s.bottom_left).to eq('bottom_left')
    expect(s.bottom_right).to eq('bottom_right')
    expect(s.full_left).to eq('full_left')
    expect(s.full_right).to eq('full_right')
    expect(s.top).to eq('top')
    expect(s.extra).to eq('extra')
  end

  it 'allows comparison with another DataItem' do
    s = Symgate::Cml::Symbol.new(symset: 'symset',
                                 main: 'main',
                                 top_left: 'top_left',
                                 top_right: 'top_right',
                                 bottom_left: 'bottom_left',
                                 bottom_right: 'bottom_right',
                                 full_left: 'full_left',
                                 full_right: 'full_right',
                                 top: 'top',
                                 extra: 'extra')

    s2 = Symgate::Cml::Symbol.new(symset: 'a',
                                  main: 'b',
                                  top_left: 'c',
                                  top_right: 'd',
                                  bottom_left: 'e',
                                  bottom_right: 'f',
                                  full_left: 'g',
                                  full_right: 'h',
                                  top: 'i',
                                  extra: 'j')

    expect(s == s2).to be_falsey

    s2.symset = 'symset'
    expect(s == s2).to be_falsey

    s2.main = 'main'
    expect(s == s2).to be_falsey

    s2.top_left = 'top_left'
    expect(s == s2).to be_falsey

    s2.top_right = 'top_right'
    expect(s == s2).to be_falsey

    s2.bottom_left = 'bottom_left'
    expect(s == s2).to be_falsey

    s2.bottom_right = 'bottom_right'
    expect(s == s2).to be_falsey

    s2.full_left = 'full_left'
    expect(s == s2).to be_falsey

    s2.full_right = 'full_right'
    expect(s == s2).to be_falsey

    s2.top = 'top'
    expect(s == s2).to be_falsey

    s2.extra = 'extra'
    expect(s == s2).to be_truthy
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Cml::Symbol.new(teapot: false) }.to raise_error(Symgate::Error)
  end

  it 'generates a string summary of the object' do
    s = Symgate::Cml::Symbol.new(main: 'stretch.svg')

    expect(s.to_s).to be_a(String)
    expect(s.to_s).to include('stretch.svg')
  end
end
