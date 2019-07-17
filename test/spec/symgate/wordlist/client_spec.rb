require_relative '../../spec_helper.rb'

require 'symgate/wordlist/client'
require 'base64'

# rubocop:disable Style/DateTime

RSpec.describe(Symgate::Wordlist::Client) do
  describe '#enumerate_wordlists' do
    it 'returns an empty array if there are no wordlists' do
      savon.expects(:enumerate_wordlists)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_wordlists_empty.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.enumerate_wordlists).to match_array([])
    end

    it 'returns an array of one Item if there is one item' do
      savon.expects(:enumerate_wordlists)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_wordlists_one.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.enumerate_wordlists).to match_array(
        [
          Symgate::Wordlist::Info.new(name: 'foo',
                                      uuid: '1c257ded-4e07-4fcf-be72-2126f368cecd',
                                      entry_count: 10,
                                      last_change: DateTime.parse('2012-10-10T10:10:10'),
                                      engine: 'sql',
                                      scope: 'User',
                                      context: 'User')
        ]
      )
    end

    it 'returns an array of two Items if there are two items' do
      savon.expects(:enumerate_wordlists)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz') })
           .returns(File.read('test/spec/fixtures/xml/enumerate_wordlists_two.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.enumerate_wordlists).to match_array(
        [
          Symgate::Wordlist::Info.new(name: 'foo',
                                      uuid: '1c257ded-4e07-4fcf-be72-2126f368cecd',
                                      entry_count: 10,
                                      last_change: DateTime.parse('2012-10-10T10:10:10'),
                                      engine: 'sql',
                                      scope: 'User',
                                      context: 'User'),
          Symgate::Wordlist::Info.new(name: 'bar',
                                      uuid: '99e065ed-8055-4694-8263-b9365c79bcdb',
                                      entry_count: 11,
                                      last_change: DateTime.parse('2014-11-11T11:11:11'),
                                      engine: 'sql',
                                      scope: 'Group',
                                      context: 'Topic')
        ]
      )
    end

    it 'accepts a filter of a single context' do
      savon.expects(:enumerate_wordlists)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            context: %w[User] })
           .returns(File.read('test/spec/fixtures/xml/enumerate_wordlists_one.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.enumerate_wordlists('User')).to match_array(
        [
          Symgate::Wordlist::Info.new(name: 'foo',
                                      uuid: '1c257ded-4e07-4fcf-be72-2126f368cecd',
                                      entry_count: 10,
                                      last_change: DateTime.parse('2012-10-10T10:10:10'),
                                      engine: 'sql',
                                      scope: 'User',
                                      context: 'User')
        ]
      )
    end

    it 'accepts a filter of an array of contexts' do
      savon.expects(:enumerate_wordlists)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            context: %w[User Lexical] })
           .returns(File.read('test/spec/fixtures/xml/enumerate_wordlists_one.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect(client.enumerate_wordlists(%w[User Lexical])).to match_array(
        [
          Symgate::Wordlist::Info.new(name: 'foo',
                                      uuid: '1c257ded-4e07-4fcf-be72-2126f368cecd',
                                      entry_count: 10,
                                      last_change: DateTime.parse('2012-10-10T10:10:10'),
                                      engine: 'sql',
                                      scope: 'User',
                                      context: 'User')
        ]
      )
    end

    it 'raises an error when passed an invalid context' do
      savon.expects(:enumerate_wordlists)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            context: %w[Teapot] })
           .returns(File.read('test/spec/fixtures/xml/generic_error.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.enumerate_wordlists('Teapot') }.to raise_error(Symgate::Error)
    end
  end

  describe '#create_wordlist' do
    it 'returns information about a new wordlist when one is created' do
      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'User',
                            scope: 'User',
                            %s(wl:wordlistentry) => [] })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')

      resp = nil
      expect { resp = client.create_wordlist('foo', 'User') }.not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('User')
      expect(resp.scope).to eq('User')
      expect(resp.entry_count).to be_a(Integer)
      expect(resp.entry_count).to eq(0)
      expect(resp.uuid).to match(
        /[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/
      )
      expect(resp.last_change).to be_a(DateTime)
      expect(resp.engine).to eq('sql')
    end

    it 'accepts an array of wordlist entries when creating the wordlist' do
      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'User',
                            scope: 'User',
                            %s(wl:wordlistentry) => [{
                              %s(wl:word) => 'cat',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '5fa23e93-6844-424a-9c4d-f694dec52869',
                              %s(wl:lastchange) => '2012-10-10T10:10:10+00:00',
                              %s(wl:conceptcode) => '01234567890',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'foo.svg'
                              }]
                            }, {
                              %s(wl:word) => 'dog',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '76300f2a-c12e-40a7-9759-979e8453fe9d',
                              %s(wl:lastchange) => '2014-11-11T11:11:11+00:00',
                              %s(wl:conceptcode) => '0987654321',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'bar.svg'
                              }]
                            }] })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')

      resp = nil
      expect do
        resp = client.create_wordlist('foo',
                                      'User',
                                      [
                                        Symgate::Wordlist::Entry.new(
                                          word: 'cat',
                                          priority: 0,
                                          uuid: '5fa23e93-6844-424a-9c4d-f694dec52869',
                                          symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
                                          last_change: DateTime.new(2012, 10, 10, 10, 10, 10, 10),
                                          concept_code: '01234567890'
                                        ),
                                        Symgate::Wordlist::Entry.new(
                                          word: 'dog',
                                          priority: 0,
                                          uuid: '76300f2a-c12e-40a7-9759-979e8453fe9d',
                                          symbols: [Symgate::Cml::Symbol.new(main: 'bar.svg')],
                                          last_change: DateTime.new(2014, 11, 11, 11, 11, 11, 11),
                                          concept_code: '0987654321'
                                        )
                                      ])
      end.not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('User')
      expect(resp.scope).to eq('User')
      expect(resp.entry_count).to be_a(Integer)
      expect(resp.entry_count).to eq(0)
      expect(resp.uuid).to match(
        /[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/
      )
      expect(resp.last_change).to be_a(DateTime)
      expect(resp.engine).to eq('sql')
    end

    it 'defers to get_wordlist_info if it receives a "no wordlist for id" error' do
      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'User',
                            scope: 'User',
                            %s(wl:wordlistentry) => [{
                              %s(wl:word) => 'cat',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '5fa23e93-6844-424a-9c4d-f694dec52869',
                              %s(wl:lastchange) => '2012-10-10T10:10:10+00:00',
                              %s(wl:conceptcode) => '01234567890',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'foo.svg'
                              }]
                            }, {
                              %s(wl:word) => 'dog',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '76300f2a-c12e-40a7-9759-979e8453fe9d',
                              %s(wl:lastchange) => '2014-11-11T11:11:11+00:00',
                              %s(wl:conceptcode) => '0987654321',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'bar.svg'
                              }]
                            }] })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist_no_wordlist.xml'))
      savon.expects(:get_wordlist_info)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '{1c257ded-4e07-4fcf-be72-2126f368cecd}' })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_info.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')

      resp = nil
      expect do
        resp = client.create_wordlist('foo',
                                      'User',
                                      [
                                        Symgate::Wordlist::Entry.new(
                                          word: 'cat',
                                          priority: 0,
                                          uuid: '5fa23e93-6844-424a-9c4d-f694dec52869',
                                          symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
                                          last_change: DateTime.new(2012, 10, 10, 10, 10, 10, 10),
                                          concept_code: '01234567890'
                                        ),
                                        Symgate::Wordlist::Entry.new(
                                          word: 'dog',
                                          priority: 0,
                                          uuid: '76300f2a-c12e-40a7-9759-979e8453fe9d',
                                          symbols: [Symgate::Cml::Symbol.new(main: 'bar.svg')],
                                          last_change: DateTime.new(2014, 11, 11, 11, 11, 11, 11),
                                          concept_code: '0987654321'
                                        )
                                      ])
      end.not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('User')
      expect(resp.scope).to eq('User')
      expect(resp.entry_count).to be_a(Integer)
      expect(resp.entry_count).to eq(10)
      expect(resp.uuid).to match(
        /[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}/
      )
      expect(resp.last_change).to be_a(DateTime)
      expect(resp.engine).to eq('sql')
    end

    it 'retries 3 times on failure' do
      3.times do
        savon.expects(:create_wordlist)
             .with(message: :any)
             .returns(File.read('test/spec/fixtures/xml/generic_error.xml'))
      end

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.create_wordlist('foo', 'bar') }.to raise_error(Symgate::Error)
    end

    it 'sends group scope when using topic or sybol-set wordlists' do
      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'User',
                            scope: 'User' })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist.xml'))

      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'Topic',
                            scope: 'Group' })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist.xml'))

      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'SymbolSet',
                            scope: 'Group' })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
      expect { client.create_wordlist('foo', 'Topic') }.not_to raise_error
      expect { client.create_wordlist('foo', 'SymbolSet') }.not_to raise_error
    end

    it 'sends account scope when using lexical wordlists' do
      # note, currently you can't actually do this with the API, so it's raising an error
      savon.expects(:create_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            name: 'foo',
                            context: 'Lexical',
                            scope: 'Account' })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.create_wordlist('foo', 'Lexical') }.not_to raise_error
    end

    it 'creates a read-only wordlist' do
      savon.expects(:create_wordlist)
          .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                           name: 'foo',
                           context: 'User',
                           scope: 'User',
                           readonly: true })
          .returns(File.read('test/spec/fixtures/xml/create_readonly_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = client.create_wordlist('foo', 'User', readonly: true)
      expect(resp.readonly).to eq(true)
    end
  end

  describe '#destroy_wordlist' do
    it 'destroys a wordlist' do
      savon.expects(:destroy_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716' })
           .returns(File.read('test/spec/fixtures/xml/destroy_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')

      expect { client.destroy_wordlist('6133cfec-0972-4c90-b952-6ab7d8304716') }.not_to raise_error
    end

    it 'retries 3 times on failure' do
      3.times do
        savon.expects(:destroy_wordlist)
             .with(message: :any)
             .returns(File.read('test/spec/fixtures/xml/generic_error.xml'))
      end

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.destroy_wordlist('6133cfec-0972-4c90-b952-6ab7d8304716') }
        .to raise_error(Symgate::Error)
    end
  end

  describe '#get_wordlist_info' do
    it 'returns information about the specified wordlist' do
      savon.expects(:get_wordlist_info)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716' })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_info.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil

      expect do
        resp = client.get_wordlist_info('6133cfec-0972-4c90-b952-6ab7d8304716')
      end.not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('User')
      expect(resp.scope).to eq('User')
      expect(resp.entry_count).to be_a(Integer)
      expect(resp.entry_count).to eq(10)
      expect(resp.uuid).to eq('1c257ded-4e07-4fcf-be72-2126f368cecd')
      expect(resp.last_change).to be_a(DateTime)
      expect(resp.engine).to eq('sql')
    end
  end

  describe '#get_wordlist_entries' do
    it 'returns an empty array if there are no entries' do
      savon.expects(:get_wordlist_entries)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716' })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_entries_empty.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil

      expect do
        resp = client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716')
      end.not_to raise_error

      expect(resp).to be_a(Array)
      expect(resp.count).to eq(0)
    end

    it 'returns all wordlist entries for a wordlist' do
      savon.expects(:get_wordlist_entries)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716' })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_entries.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil

      expect do
        resp = client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716')
      end.not_to raise_error

      expect(resp).to be_a(Array)
      resp.each { |r| expect(r).to be_a(Symgate::Wordlist::Entry) }
      expect(resp.count).to eq(2)
      expect(resp.first.word).to eq('cat')
      expect(resp.first.custom_graphics).to be_a(Array)
      expect(resp.first.custom_graphics.count).to eq(0)
    end

    it 'accepts an option to return attachments' do
      savon.expects(:get_wordlist_entries)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            getattachments: true })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_entries_with_attachments.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil

      expect do
        resp = client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716',
                                           attachments: true)
      end.not_to raise_error

      expect(resp).to be_a(Array)
      resp.each { |r| expect(r).to be_a(Symgate::Wordlist::Entry) }
      expect(resp.count).to eq(2)
      expect(resp.first.word).to eq('cat')
      expect(resp.first.uuid).to eq('7bdc3511-6cb8-4d7b-9179-380afced746d')
      expect(resp[1].word).to eq('dog')
      expect(resp[1].uuid).to eq('5fa23e93-6844-424a-9c4d-f694dec52869')
      expect(resp.first.custom_graphics).to be_a(Array)
      expect(resp.first.custom_graphics.count).to eq(1)
      expect(resp.first.custom_graphics.first).to be_a(Symgate::Wordlist::GraphicAttachment)
      expect(resp.first.custom_graphics.first.data).to eq(get_kitten)
      expect(resp.first.custom_graphics.first.type).to eq('image/jpeg')
      expect(resp.first.custom_graphics.first.uuid).to eq('32295822-6965-4cd0-b2b5-4d2d91df1faf')
      expect(resp.first.symbols).to be_a(Array)
      expect(resp.first.symbols.count).to eq(1)
      expect(resp.first.symbols.first).to be_a(Symgate::Cml::Symbol)
      expect(resp.first.symbols.first.main).to eq('cat.svg')
      expect(resp.first.symbols.first.extra).to be_nil
      expect(resp.first.last_change).to be_a(DateTime)
      expect(resp.first.last_change).to eq(DateTime.parse('2012-10-10T10:10:10'))
      expect(resp.first.concept_code).to be_nil
      expect(resp.first.priority).to be_a(Integer)
      expect(resp.first.priority).to eq(1)
    end

    it 'accepts an option to specify a single entry uuid' do
      savon.expects(:get_wordlist_entries)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            match: { entryid: '7bdc3511-6cb8-4d7b-9179-380afced746d' } })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_entries_one.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil

      expect do
        resp = client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716',
                                           entry: '7bdc3511-6cb8-4d7b-9179-380afced746d')
      end.not_to raise_error

      expect(resp).to be_a(Array)
      resp.each { |r| expect(r).to be_a(Symgate::Wordlist::Entry) }
      expect(resp.count).to eq(1)
      expect(resp.first.word).to eq('cat')
      expect(resp.first.uuid).to eq('7bdc3511-6cb8-4d7b-9179-380afced746d')
      expect(resp.first.custom_graphics).to be_a(Array)
      expect(resp.first.custom_graphics.count).to eq(0)
    end

    it 'accepts an option to filter by word' do
      savon.expects(:get_wordlist_entries)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            match: { matchstring: 'cat' } })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_entries_one.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil

      expect do
        resp = client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716',
                                           match: 'cat')
      end.not_to raise_error

      expect(resp).to be_a(Array)
      resp.each { |r| expect(r).to be_a(Symgate::Wordlist::Entry) }
      expect(resp.count).to eq(1)
      expect(resp.first.word).to eq('cat')
      expect(resp.first.uuid).to eq('7bdc3511-6cb8-4d7b-9179-380afced746d')
      expect(resp.first.custom_graphics).to be_a(Array)
      expect(resp.first.custom_graphics.count).to eq(0)
    end

    it 'raises an error if both a word and concept filter are supplied' do
      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')

      expect do
        client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716',
                                    match: 'cat',
                                    entry: '7bdc3511-6cb8-4d7b-9179-380afced746d')
      end.to raise_error(Symgate::Error).with_message("Supply only one of 'match' or 'entry'")
    end

    it 'raises an error if an unknown option is supplied' do
      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')

      expect do
        client.get_wordlist_entries('6133cfec-0972-4c90-b952-6ab7d8304716',
                                    teapot: 'green')
      end.to raise_error(Symgate::Error).with_message('Unknown option: teapot')
    end
  end

  describe '#insert_wordlist_entry' do
    it 'inserts an entry into a wordlist' do
      savon.expects(:insert_wordlist_entry)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            %s(wl:wordlistentry) => {
                              %s(wl:word) => 'cat',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '5fa23e93-6844-424a-9c4d-f694dec52869',
                              %s(wl:lastchange) => '2012-10-10T10:10:10+00:00',
                              %s(wl:conceptcode) => '01234567890',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'foo.svg'
                              }]
                            } })
           .returns(File.read('test/spec/fixtures/xml/insert_wordlist_entry.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect do
        client.insert_wordlist_entry(
          '6133cfec-0972-4c90-b952-6ab7d8304716',
          Symgate::Wordlist::Entry.new(
            word: 'cat',
            priority: 0,
            uuid: '5fa23e93-6844-424a-9c4d-f694dec52869',
            symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
            last_change: DateTime.new(2012, 10, 10, 10, 10, 10, 10),
            concept_code: '01234567890'
          )
        )
      end.not_to raise_error
    end

    it 'sends attached graphic data as base64-encoded' do
      savon.expects(:insert_wordlist_entry)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            %s(wl:wordlistentry) => {
                              %s(wl:word) => 'cat',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '5fa23e93-6844-424a-9c4d-f694dec52869',
                              %s(wl:lastchange) => '2012-10-10T10:10:10+00:00',
                              %s(wl:conceptcode) => '01234567890',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'foo.svg'
                              }],
                              %s(wl:customgraphic) => [{
                                %s(wl:type) => 'image/jpeg',
                                %s(wl:uuid) => '76300f2a-c12e-40a7-9759-979e8453fe9d',
                                %s(wl:data) => Base64.encode64(get_kitten)
                              }]
                            } })
           .returns(File.read('test/spec/fixtures/xml/insert_wordlist_entry.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect do
        client.insert_wordlist_entry(
          '6133cfec-0972-4c90-b952-6ab7d8304716',
          Symgate::Wordlist::Entry.new(
            word: 'cat',
            priority: 0,
            uuid: '5fa23e93-6844-424a-9c4d-f694dec52869',
            symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
            last_change: DateTime.new(2012, 10, 10, 10, 10, 10, 10),
            concept_code: '01234567890',
            custom_graphics: [
              Symgate::Wordlist::GraphicAttachment.new(
                type: 'image/jpeg',
                data: get_kitten,
                uuid: '76300f2a-c12e-40a7-9759-979e8453fe9d'
              )
            ]
          )
        )
      end.not_to raise_error
    end

    it 'throws an error if passed something other than a wordlist entry' do
      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect { client.insert_wordlist_entry('6133cfec-0972-4c90-b952-6ab7d8304716', 'teapot') }
        .to raise_error(Symgate::Error)
    end
  end

  describe '#overwrite_wordlist' do
    it 'overwrites a wordlist when passed a uuid and array of entries' do
      savon.expects(:overwrite_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            %s(wl:wordlistentry) => [{
                              %s(wl:word) => 'cat',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '5fa23e93-6844-424a-9c4d-f694dec52869',
                              %s(wl:lastchange) => '2012-10-10T10:10:10+00:00',
                              %s(wl:conceptcode) => '01234567890',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'foo.svg'
                              }]
                            }, {
                              %s(wl:word) => 'dog',
                              %s(wl:priority) => 0,
                              %s(wl:uuid) => '76300f2a-c12e-40a7-9759-979e8453fe9d',
                              %s(wl:lastchange) => '2014-11-11T11:11:11+00:00',
                              %s(wl:conceptcode) => '0987654321',
                              %s(cml:symbol) => [{
                                %s(cml:main) => 'bar.svg'
                              }]
                            }] })
           .returns(File.read('test/spec/fixtures/xml/overwrite_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect do
        client.overwrite_wordlist(
          '6133cfec-0972-4c90-b952-6ab7d8304716',
          [
            Symgate::Wordlist::Entry.new(
              word: 'cat',
              priority: 0,
              uuid: '5fa23e93-6844-424a-9c4d-f694dec52869',
              symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
              last_change: DateTime.new(2012, 10, 10, 10, 10, 10, 10),
              concept_code: '01234567890'
            ),
            Symgate::Wordlist::Entry.new(
              word: 'dog',
              priority: 0,
              uuid: '76300f2a-c12e-40a7-9759-979e8453fe9d',
              symbols: [Symgate::Cml::Symbol.new(main: 'bar.svg')],
              last_change: DateTime.new(2014, 11, 11, 11, 11, 11, 11),
              concept_code: '0987654321'
            )
          ]
        )
      end.not_to raise_error
    end

    it 'throws an error if passed something other than an array of wordlist entries' do
      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect do
        client.overwrite_wordlist(
          '6133cfec-0972-4c90-b952-6ab7d8304716',
          Symgate::Wordlist::Entry.new(
            word: 'cat',
            priority: 0,
            uuid: '5fa23e93-6844-424a-9c4d-f694dec52869',
            symbols: [Symgate::Cml::Symbol.new(main: 'foo.svg')],
            last_change: DateTime.new(2012, 10, 10, 10, 10, 10, 10),
            concept_code: '01234567890'
          )
        )
      end.to raise_error(Symgate::Error)
    end
  end

  describe '#remove_wordlist_entry' do
    it 'removes a wordlist entry when passed wordlist and entry uuids' do
      savon.expects(:remove_wordlist_entry)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            entryid: '5fa23e93-6844-424a-9c4d-f694dec52869' })
           .returns(File.read('test/spec/fixtures/xml/remove_wordlist_entry.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect do
        client.remove_wordlist_entry('6133cfec-0972-4c90-b952-6ab7d8304716',
                                     '5fa23e93-6844-424a-9c4d-f694dec52869')
      end.not_to raise_error
    end
  end

  describe '#rename_wordlist' do
    it 'renames a wordlist when passed a uuid and name' do
      savon.expects(:rename_wordlist)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716',
                            name: 'foo' })
           .returns(File.read('test/spec/fixtures/xml/rename_wordlist.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      expect do
        client.rename_wordlist('6133cfec-0972-4c90-b952-6ab7d8304716',
                               'foo')
      end.not_to raise_error
    end
  end

  describe '#get_wordlist_as_cfwl_data' do
    it 'returns a cfwl in binary format' do
      savon.expects(:get_wordlist_as_cfwl_data)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716' })
           .returns(File.read('test/spec/fixtures/xml/get_wordlist_as_cfwl_data.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil
      expect do
        resp = client.get_wordlist_as_cfwl_data('6133cfec-0972-4c90-b952-6ab7d8304716')
      end.not_to raise_error

      expect(resp).to eq(get_cfwl)
    end
  end

  describe '#create_wordlist_from_cfwl_data' do
    it 'sends the cfwl data in base64 format and returns the uuid of the new list' do
      savon.expects(:create_wordlist_from_cfwl_data)
           .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                            cfwl: Base64.encode64(get_cfwl),
                            context: 'User',
                            preserve_uuid: true })
           .returns(File.read('test/spec/fixtures/xml/create_wordlist_from_cfwl_data.xml'))

      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      resp = nil
      expect do
        resp = client.create_wordlist_from_cfwl_data(get_cfwl, 'User', true)
      end.not_to raise_error

      expect(resp).to eq('6133cfec-0972-4c90-b952-6ab7d8304716')
    end

    it 'creates a read-only wordlist' do
      savon.expects(:create_wordlist_from_cfwl_data)
          .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                           cfwl: Base64.encode64(get_cfwl),
                           context: 'User',
                           preserve_uuid: true })
          .returns(File.read('test/spec/fixtures/xml/create_wordlist_from_cfwl_data.xml'))
      client = Symgate::Wordlist::Client.new(account: 'foo', user: 'foo/bar', password: 'baz')
      uuid = nil
      expect do
        uuid = client.create_wordlist_from_cfwl_data(get_cfwl, 'User', true, readonly: true)
      end.not_to raise_error

      savon.expects(:get_wordlist_info)
          .with(message: { %s(auth:creds) => user_password_creds('foo', 'foo/bar', 'baz'),
                           wordlistid: '6133cfec-0972-4c90-b952-6ab7d8304716' })
          .returns(File.read('test/spec/fixtures/xml/get_wordlist_info_readonly.xml'))
      resp = nil
      expect do
        resp = client.get_wordlist_info(uuid)
      end.not_to raise_error

      expect(resp.readonly).to eq(true)
    end
  end
end

# rubocop:enable Style/DateTime
