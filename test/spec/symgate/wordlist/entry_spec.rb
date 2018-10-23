require_relative '../../spec_helper.rb'

require 'symgate/wordlist/entry'
require 'symgate/cml/symbol'

# rubocop:disable Style/DateTime

RSpec.describe(Symgate::Wordlist::Entry) do
  it 'allows direct access to the wordlist entry attributes' do
    e = Symgate::Wordlist::Entry.new
    e.word = 'cat'
    e.uuid = 'f7a23690-534a-0134-9ec1-20cf302b46f2'
    e.concept_code = '01234567890'
    e.last_change = DateTime.now
    e.priority = 2
    e.symbols = [Symgate::Cml::Symbol.new(main: 'foo.svg')]
    e.custom_graphics = [
      Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                               data: get_kitten,
                                               uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
    ]

    expect(e.word).to eq('cat')
    expect(e.uuid).to eq('f7a23690-534a-0134-9ec1-20cf302b46f2')
    expect(e.concept_code).to eq('01234567890')
    expect(e.last_change).to be_a(DateTime)
    expect(e.last_change).to be > DateTime.now - 30
    expect(e.priority).to eq(2)
    expect(e.symbols).to be_a(Array)
    expect(e.symbols.count).to eq(1)
    expect(e.symbols.first).to be_a(Symgate::Cml::Symbol)
    expect(e.symbols.first.main).to eq('foo.svg')
    expect(e.custom_graphics).to be_a(Array)
    expect(e.custom_graphics.count).to eq(1)
    expect(e.custom_graphics.first).to be_a(Symgate::Wordlist::GraphicAttachment)
    expect(e.custom_graphics.first.uuid).to eq('4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
  end

  it 'allows construction from a hash' do
    e = Symgate::Wordlist::Entry.new(
      word: 'cat',
      uuid: 'f7a23690-534a-0134-9ec1-20cf302b46f2',
      concept_code: '01234567890',
      last_change: DateTime.now,
      priority: 2,
      symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
      custom_graphics: [
        Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 data: get_kitten,
                                                 uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
      ]
    )

    expect(e.word).to eq('cat')
    expect(e.uuid).to eq('f7a23690-534a-0134-9ec1-20cf302b46f2')
    expect(e.concept_code).to eq('01234567890')
    expect(e.last_change).to be_a(DateTime)
    expect(e.last_change).to be > DateTime.now - 30
    expect(e.priority).to eq(2)
    expect(e.symbols).to be_a(Array)
    expect(e.symbols.count).to eq(1)
    expect(e.symbols.first).to be_a(Symgate::Cml::Symbol)
    expect(e.symbols.first.main).to eq('foo.svg')
    expect(e.custom_graphics).to be_a(Array)
    expect(e.custom_graphics.count).to eq(1)
    expect(e.custom_graphics.first).to be_a(Symgate::Wordlist::GraphicAttachment)
    expect(e.custom_graphics.first.uuid).to eq('4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
  end

  it 'allows comparison with another Entry' do
    d1 = DateTime.now
    d2 = DateTime.now - 60

    e = Symgate::Wordlist::Entry.new(
      word: 'cat',
      uuid: 'f7a23690-534a-0134-9ec1-20cf302b46f2',
      concept_code: '01234567890',
      last_change: d1,
      priority: 2,
      symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
      custom_graphics: [
        Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 data: get_kitten,
                                                 uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
      ]
    )

    e2 = e.dup

    check_comparison_operator_for_member(e, e2, :word, 'dog', 'cat')
    check_comparison_operator_for_member(e, e2, :uuid,
                                         '8bd86e10-5576-0134-9ec1-20cf302b46f2',
                                         'f7a23690-534a-0134-9ec1-20cf302b46f2')
    check_comparison_operator_for_member(e, e2, :concept_code, '09876543210', '01234567890')
    check_comparison_operator_for_member(e, e2, :last_change, d2, d1)
    check_comparison_operator_for_member(e, e2, :priority, 1, 2)
    check_comparison_operator_for_member(e, e2, :symbols,
                                         [Symgate::Cml::Symbol.new(main: 'bar.svg')],
                                         [Symgate::Cml::Symbol.new(main: 'foo.svg')])
    check_comparison_operator_for_member(
      e, e2, :custom_graphics,
      [
        Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 data: get_kitten(:alternate),
                                                 uuid: 'f7a23690-534a-0134-9ec1-20cf302b46f2')
      ],
      [
        Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 data: get_kitten,
                                                 uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
      ]
    )
  end

  it 'raises an error when created with an unknown parameter' do
    expect { Symgate::Wordlist::GraphicAttachment.new(teapot: false) }
      .to raise_error(Symgate::Error)
  end

  it 'generates a string summary of the object' do
    e = Symgate::Wordlist::Entry.new(
      word: 'cat',
      uuid: 'f7a23690-534a-0134-9ec1-20cf302b46f2',
      concept_code: '01234567890',
      last_change: DateTime.now,
      priority: 2,
      symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
      custom_graphics: [
        Symgate::Wordlist::GraphicAttachment.new(type: 'image/jpeg',
                                                 data: get_kitten,
                                                 uuid: '4c1ef7d0-5357-0134-9ec1-20cf302b46f2')
      ]
    )

    expect(e.to_s).to be_a(String)
    expect(e.to_s).to include('cat')
    expect(e.to_s).to include('[2]')
    expect(e.to_s).to include('f7a23690-534a-0134-9ec1-20cf302b46f2')
  end
end

# rubocop:enable Style/DateTime
