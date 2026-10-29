require_relative '../../spec_helper.rb'

require 'symgate/wordlist/custom_nlp'

RSpec.describe(Symgate::Wordlist::CustomNlp) do
  it 'round-trips base, pos, tags, and conceptcode in schema order' do
    nlp = Symgate::Wordlist::CustomNlp.new(base: 'cat', pos: 'NN', tags: 'sg', conceptcode: '0123')

    expect(nlp.to_soap.keys).to eq(%i[wl:base wl:pos wl:tags wl:conceptcode])
    expect(nlp.to_s).to include('cat')
    expect(Symgate::Wordlist::CustomNlp.from_soap(nlp.to_soap)).to eq(nlp)
  end

  it 'reads namespaced soap keys' do
    nlp = Symgate::Wordlist::CustomNlp.from_soap(
      %s(wl:base) => 'cat',
      %s(wl:pos) => 'NN',
      %s(wl:tags) => 'sg',
      %s(wl:conceptcode) => '0123'
    )

    expect(nlp.base).to eq('cat')
    expect(nlp.conceptcode).to eq('0123')
  end
end
