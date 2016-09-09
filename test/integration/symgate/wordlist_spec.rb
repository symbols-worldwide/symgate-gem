require_relative '../spec_helper.rb'

require 'symgate/auth/client'
require 'symgate/wordlist/client'
require 'symgate/wordlist/entry'

RSpec.describe(Symgate::Wordlist::Client) do
  def client
    user_password_client_of_type(Symgate::Wordlist::Client, 'foo/bar', 'baz')
  end

  def non_admin_client
    user_password_client_of_type(Symgate::Wordlist::Client, 'foo/baz', 'qux')
  end

  def account_key_client
    account_key_client_of_type(Symgate::Wordlist::Client)
  end

  before(:each) do
    auth_client = account_key_client_of_type(Symgate::Auth::Client)
    auth_client.create_group('foo')

    [
      [Symgate::Auth::User.new(user_id: 'foo/bar', is_group_admin: true), 'baz'],
      [Symgate::Auth::User.new(user_id: 'foo/baz', is_group_admin: false), 'qux']
    ].each { |u| auth_client.create_user(u[0], u[1]) }
  end

  describe '#create_wordlist' do
    it 'allows an admin user to create a user wordlist' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
    end

    it 'allows a non-admin user to create a user wordlist' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
    end

    it 'returns a wordlist info object about the newly-created wordlist' do
      resp = nil

      expect { resp = client.create_wordlist('foo', 'User') }
        .not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('User')
      expect(resp.entry_count).to be_a(Integer)
      expect(resp.entry_count).to eq(0)
      expect(resp.last_change).to be_a(DateTime)
      expect(resp.last_change).to be > DateTime.now - 30
      expect(resp.last_change).to be < DateTime.now
      expect(resp.engine).to eq('sql')
      expect(resp.uuid).to match(/^{[0-9a-f-]{36}}$/)
    end

    it 'allows an admin user to create a topic wordlist' do
      resp = nil

      expect { resp = client.create_wordlist('foo', 'Topic') }
        .not_to raise_error

      expect(resp).to be_a(Symgate::Wordlist::Info)
      expect(resp.name).to eq('foo')
      expect(resp.context).to eq('Topic')
    end

    # TODO: Disabled. See CL-9949
    # it 'raises an error when a non-admin user creates a topic wordlist' do
    #   expect { non_admin_client.create_wordlist('foo', 'Topic') }
    #     .to raise_error(Symgate::Error)
    # end

    it 'raises an error when trying to create a lexical wordlist' do
      expect { client.create_wordlist('foo', 'Lexical') }
        .to raise_error(Symgate::Error)
    end

    it 'raises an error when trying to create a wordlist with an account/key client' do
      expect { account_key_client.create_wordlist('foo', 'Lexical') }
        .to raise_error(Symgate::Error)

      expect { account_key_client.create_wordlist('foo', 'User') }
        .to raise_error(Symgate::Error)
    end

    it 'creates a wordlist with a wordlist entry if one is supplied' do
      resp = nil

      expect do
        resp = client.create_wordlist(
          'foo',
          'User',
          [
            Symgate::Wordlist::Entry.new(
              word: 'cat',
              uuid: 'c0fb70eb-0833-4572-86ef-cdb8edf8a6c1',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'foo.svg')
              ]
            )
          ]
        )
      end.not_to raise_error

      expect(resp.entry_count).to eq(1)
      expect(client.get_wordlist_info(resp.uuid).entry_count).to eq(1)
    end
  end

  describe '#enumerate_wordlists' do
    it 'returns an empty array when there are no wordlists' do
      expect(client.enumerate_wordlists).to match_array([])
    end

    it 'returns a list of all wordlists when there are several' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
      expect { client.create_wordlist('bar', 'Topic') }.not_to raise_error
      expect { client.create_wordlist('baz', 'SymbolSet') }.not_to raise_error

      resp = nil
      expect { resp = client.enumerate_wordlists }.not_to raise_error

      expect(resp).to be_a(Array)
      expect(resp.count).to eq(3)
      resp.each do |info|
        expect(info.last_change).to be_a(DateTime)
        expect(info.last_change).to be > DateTime.now - 30
        expect(info.entry_count).to eq(0)
        expect(info.engine).to eq('sql')
        expect(info.uuid).to match(/^{[0-9a-f-]{36}}$/)
      end
      expect(resp.count { |info| info.name == 'foo' && info.context == 'User' }).to eq(1)
      expect(resp.count { |info| info.name == 'bar' && info.context == 'Topic' }).to eq(1)
      expect(resp.count { |info| info.name == 'baz' && info.context == 'SymbolSet' }).to eq(1)
    end

    it 'returns a list of wordlists limited by a single scope, when passed a scope string' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
      expect { client.create_wordlist('bar', 'Topic') }.not_to raise_error
      expect { client.create_wordlist('baz', 'SymbolSet') }.not_to raise_error

      resp = nil
      expect { resp = client.enumerate_wordlists('SymbolSet') }.not_to raise_error

      expect(resp).to be_a(Array)
      expect(resp.count).to eq(1)
      expect(resp.first.name).to eq('baz')
      expect(resp.first.context).to eq('SymbolSet')
    end

    it 'returns a list of wordlists limited by scopes, when passed an array of scope strings' do
      expect { client.create_wordlist('foo', 'User') }.not_to raise_error
      expect { client.create_wordlist('bar', 'Topic') }.not_to raise_error
      expect { client.create_wordlist('baz', 'SymbolSet') }.not_to raise_error

      resp = nil
      expect { resp = client.enumerate_wordlists(%w(SymbolSet User)) }.not_to raise_error

      expect(resp).to be_a(Array)
      expect(resp.count).to eq(2)
      expect(resp.count { |info| info.name == 'foo' && info.context == 'User' }).to eq(1)
      expect(resp.count { |info| info.name == 'baz' && info.context == 'SymbolSet' }).to eq(1)

      expect(resp.count { |info| info.name == 'bar' && info.context == 'Topic' }).to eq(0)
    end

    it 'raises an error when passed an invalid context' do
      expect { client.enumerate_wordlists('Teapot') }
        .to raise_error(Symgate::Error)
    end

    it 'raises an error when passed an invalid context in an array' do
      expect { client.enumerate_wordlists(%w(User Topic Teapot SymbolSet)) }
        .to raise_error(Symgate::Error)
    end
  end

  describe '#destroy_wordlst' do
    it 'raises an error if the wordlist does not exist' do
      expect { client.destroy_wordlist('c0fb70eb-0833-4572-86ef-cdb8edf8a6c1') }
        .to raise_error(Symgate::Error)
    end

    it 'deletes a user wordlist' do
      resp = nil
      expect(client.enumerate_wordlists.count).to eq(0)
      expect { resp = client.create_wordlist('foo', 'User') }.not_to raise_error
      expect(client.enumerate_wordlists.count).to eq(1)

      expect { client.destroy_wordlist(resp.uuid) }.not_to raise_error
      expect(client.enumerate_wordlists.count).to eq(0)
    end

    it 'deletes a topic wordlist' do
      resp = nil
      expect(client.enumerate_wordlists.count).to eq(0)
      expect { resp = client.create_wordlist('foo', 'Topic') }.not_to raise_error
      expect(client.enumerate_wordlists.count).to eq(1)

      expect { client.destroy_wordlist(resp.uuid) }.not_to raise_error
      expect(client.enumerate_wordlists.count).to eq(0)
    end
  end

  describe '#get_wordlist_info' do
    it 'raises an error if the wordlist does not exist' do
      expect { client.get_wordlist_info('c0fb70eb-0833-4572-86ef-cdb8edf8a6c1') }
        .to raise_error(Symgate::Error)
    end

    it 'gets information about a wordlist' do
      resp = nil
      expect(client.enumerate_wordlists.count).to eq(0)
      expect { resp = client.create_wordlist('foo', 'User') }.not_to raise_error
      expect(client.enumerate_wordlists.count).to eq(1)

      expect { client.get_wordlist_info(resp.uuid) }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid)).to eq(resp)
    end
  end

  describe '#rename_wordlist' do
    it 'raises an error if the wordlist does not exist' do
      expect { client.rename_wordlist('c0fb70eb-0833-4572-86ef-cdb8edf8a6c1', 'teapot') }
        .to raise_error(Symgate::Error)
    end

    it 'renames a wordlist' do
      resp = nil
      expect { resp = client.create_wordlist('foo', 'User') }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid).name).to eq('foo')

      expect { client.rename_wordlist(resp.uuid, 'teapot') }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid).name).to eq('teapot')
    end

    it 'does not raise an error if the new name is the same as the old one' do
      resp = nil
      expect { resp = client.create_wordlist('foo', 'User') }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid).name).to eq('foo')

      expect { client.rename_wordlist(resp.uuid, 'foo') }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid).name).to eq('foo')
    end

    it 'allows two wordlists with the same name' do
      resp = nil
      resp2 = nil
      expect { resp = client.create_wordlist('foo', 'User') }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid).name).to eq('foo')
      expect { resp2 = client.create_wordlist('bar', 'User') }.not_to raise_error
      expect(client.get_wordlist_info(resp2.uuid).name).to eq('bar')

      expect { client.rename_wordlist(resp.uuid, 'bar') }.not_to raise_error

      expect { resp = client.enumerate_wordlists }.not_to raise_error
      expect(resp[0].name).to eq(resp[1].name)
      expect(resp[0].uuid).not_to eq(resp[1].uuid)
    end
  end

  describe '#overwrite_wordlist' do
    it 'raises an error if the wordlist does not exist' do
      expect { client.overwrite_wordlist('c0fb70eb-0833-4572-86ef-cdb8edf8a6c1', []) }
        .to raise_error(Symgate::Error)
    end

    it 'empties a wordlist if no entries are passed' do
      resp = nil

      expect do
        resp = client.create_wordlist(
          'foo',
          'User',
          [
            Symgate::Wordlist::Entry.new(
              word: 'cat',
              uuid: 'c0fb70eb-0833-4572-86ef-cdb8edf8a6c1',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'foo.svg')
              ]
            )
          ]
        )
      end.not_to raise_error

      expect(resp.entry_count).to eq(1)
      expect(client.get_wordlist_info(resp.uuid).entry_count).to eq(1)

      expect { client.overwrite_wordlist(resp.uuid, []) }.not_to raise_error
      expect(client.get_wordlist_info(resp.uuid).entry_count).to eq(0)
    end

    it 'replaces the contents of the wordlist' do
      resp = nil
      expect do
        resp = client.create_wordlist(
          'foo',
          'User',
          [
            Symgate::Wordlist::Entry.new(
              word: 'cat',
              uuid: 'c0fb70eb-0833-4572-86ef-cdb8edf8a6c1',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'foo.svg')
              ]
            ),
            Symgate::Wordlist::Entry.new(
              word: 'bar',
              uuid: '6518be5d-b989-4adf-b076-e787ed53cb88',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'bar.svg')
              ]
            )
          ]
        )
      end.not_to raise_error

      expect(resp.entry_count).to eq(2)

      expect do
        client.overwrite_wordlist(
          resp.uuid,
          [
            Symgate::Wordlist::Entry.new(
              word: 'baz',
              uuid: '8779812d-2293-454f-b299-47e8dee4fa8f',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'baz.svg')
              ]
            ),
            Symgate::Wordlist::Entry.new(
              word: 'qux',
              uuid: '7596d217-1728-4707-a594-f92ab736eee7',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'qux.svg')
              ]
            ),
            Symgate::Wordlist::Entry.new(
              word: 'quux',
              uuid: '656c8dcb-3aa3-44a3-96d6-e7d11e3f37a4',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'quux.svg')
              ]
            )
          ]
        )
      end.not_to raise_error

      expect(client.get_wordlist_info(resp.uuid).entry_count).to eq(3)

      entries = nil
      expect { entries = client.get_wordlist_entries(resp.uuid) }.not_to raise_error

      expect(entries).to be_a(Array)
      expect(entries.count).to eq(3)

      expect(entries.count { |entry| entry.word == 'foo' }).to eq(0)
      expect(entries.count { |entry| entry.word == 'baz' }).to eq(1)
      expect(entries.count { |entry| entry.word == 'qux' }).to eq(1)
      expect(entries.count { |entry| entry.word == 'quux' }).to eq(1)
    end
  end

  describe '#insert_wordlist_entry' do
    it 'raises an error if the wordlist does not exist' do
      expect do
        client.insert_wordlist_entry(
          '656c8dcb-3aa3-44a3-96d6-e7d11e3f37a4',
          Symgate::Wordlist::Entry.new(
            word: 'baz',
            uuid: '8779812d-2293-454f-b299-47e8dee4fa8f',
            priority: 0,
            symbols: [
              Symgate::Cml::Symbol.new(main: 'baz.svg')
            ]
          )
        )
      end.to raise_error(Symgate::Error)
    end

    it 'inserts a wordlist entry' do
      uuid = nil
      expect { uuid = client.create_wordlist('foo', 'User').uuid }.not_to raise_error
      expect(client.get_wordlist_info(uuid).entry_count).to eq(0)

      expect do
        client.insert_wordlist_entry(
          uuid,
          Symgate::Wordlist::Entry.new(
            word: 'baz',
            uuid: '8779812d-2293-454f-b299-47e8dee4fa8f',
            priority: 0,
            symbols: [
              Symgate::Cml::Symbol.new(main: 'baz.svg')
            ]
          )
        )
      end.not_to raise_error

      expect(client.get_wordlist_info(uuid).entry_count).to eq(1)

      entry = nil
      expect { entry = client.get_wordlist_entries(uuid).first }.not_to raise_error

      expect(entry.word).to eq('baz')
      expect(entry.uuid).to eq('{8779812d-2293-454f-b299-47e8dee4fa8f}')
      expect(entry.priority).to eq(0)
      expect(entry.symbols).to match_array(
        [
          Symgate::Cml::Symbol.new(main: 'baz.svg')
        ]
      )
      expect(entry.custom_graphics).to match_array([])
      expect(entry.last_change).to be_a(DateTime)
      expect(entry.last_change).to be > DateTime.now - 30
    end

    it 'inserts an entry with a binary attachment' do
      uuid = nil
      expect { uuid = client.create_wordlist('foo', 'User').uuid }.not_to raise_error
      expect(client.get_wordlist_info(uuid).entry_count).to eq(0)

      expect do
        client.insert_wordlist_entry(
          uuid,
          Symgate::Wordlist::Entry.new(
            word: 'baz',
            uuid: '8779812d-2293-454f-b299-47e8dee4fa8f',
            priority: 0,
            symbols: [
              Symgate::Cml::Symbol.new(main: 'baz.svg')
            ],
            custom_graphics: [
              Symgate::Wordlist::GraphicAttachment.new(
                type: 'image/jpeg',
                uuid: 'b563f100-08c2-428d-afdb-302f0f7608d9',
                data: get_kitten
              )
            ]
          )
        )
      end.not_to raise_error

      expect(client.get_wordlist_info(uuid).entry_count).to eq(1)

      entry = nil
      expect { entry = client.get_wordlist_entries(uuid, attachments: true).first }
        .not_to raise_error

      expect(entry.word).to eq('baz')
      expect(entry.uuid).to eq('{8779812d-2293-454f-b299-47e8dee4fa8f}')
      expect(entry.priority).to eq(0)

      expect(entry.custom_graphics).to match_array(
        [
          Symgate::Wordlist::GraphicAttachment.new(
            type: 'image/jpeg',
            uuid: '{b563f100-08c2-428d-afdb-302f0f7608d9}',
            data: get_kitten
          )
        ]
      )
    end

    it 'automatically generates uuids for entries with no uuid' do
      uuid = nil
      expect { uuid = client.create_wordlist('foo', 'User').uuid }.not_to raise_error
      expect(client.get_wordlist_info(uuid).entry_count).to eq(0)

      expect do
        client.insert_wordlist_entry(
          uuid,
          Symgate::Wordlist::Entry.new(
            word: 'baz',
            priority: 0
          )
        )
      end.not_to raise_error

      entry = nil
      expect { entry = client.get_wordlist_entries(uuid).first }.not_to raise_error

      expect(entry.uuid).to match(/^{[0-9a-f-]{36}}$/)
    end
  end

  describe '#remove_wordlist_entry' do
    it 'raises an error if the wordlist does not exist' do
      expect do
        client.remove_wordlist_entry(
          'fe5a7237-6594-4a8c-93f5-de26b926aefa',
          'd0621aac-e2f4-4bd1-b2a9-2e21c2b1ed0c'
        )
      end.to raise_error(Symgate::Error)
    end

    # TODO: The API treats this as success. Is this what we want?
    # it 'raises an error if the entry does not exist' do
    #   uuid = nil
    #   expect { uuid = client.create_wordlist('foo', 'User').uuid }.not_to raise_error
    #   expect(client.get_wordlist_info(uuid).entry_count).to eq(0)
    #
    #   expect do
    #     client.remove_wordlist_entry(
    #       uuid,
    #       'd0621aac-e2f4-4bd1-b2a9-2e21c2b1ed0c'
    #     )
    #   end.to raise_error(Symgate::Error)
    # end

    it 'removes a wordlist entry' do
      uuid = nil
      expect do
        uuid = client.create_wordlist(
          'foo',
          'User',
          [
            Symgate::Wordlist::Entry.new(
              word: 'cat',
              uuid: 'c0fb70eb-0833-4572-86ef-cdb8edf8a6c1',
              priority: 0,
              symbols: [
                Symgate::Cml::Symbol.new(main: 'foo.svg')
              ]
            )
          ]
        ).uuid
      end.not_to raise_error
      expect(client.get_wordlist_info(uuid).entry_count).to eq(1)

      expect do
        client.remove_wordlist_entry(
          uuid,
          client.get_wordlist_entries(uuid).first.uuid
        )
      end.not_to raise_error

      expect(client.get_wordlist_info(uuid).entry_count).to eq(0)
    end
  end
end
