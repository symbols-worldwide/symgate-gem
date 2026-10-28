require_relative '../spec_helper.rb'

require 'symgate/client'

RSpec.describe(Symgate::Client) do
  describe '#initialize' do
    it 'throws a Symgate error when called with no parameters' do
      expect { Symgate::Client.new }.to raise_error(
        Symgate::Error, 'No account specified'
      )
    end

    it 'throws a Symgate error when called with an account, but no key or user' do
      expect { client_of_type(Symgate::Client, account: 'foo') }.to raise_error(
        Symgate::Error, 'No key or user specified'
      )
    end

    it 'throws a Symgate error when called with both a key and user' do
      expect { client_of_type(Symgate::Client, account: 'foo', key: 'bar', user: 'baz') }.to raise_error(
        Symgate::Error, 'Both key and user were specified'
      )
    end

    it 'allows three data required attempts by default' do
      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')

      expect(client.data_required_error_retries).to eq(3)
    end

    it 'create a valid client if an account and key are specified' do
      client = nil
      expect { client = client_of_type(Symgate::Client, account: 'foo', key: 'bar') }.not_to raise_error
      expect(client.savon_client).to be_a(Savon::Client)
    end

    it 'throws a Symgate error when called with a user but no password or token' do
      expect { client_of_type(Symgate::Client, account: 'foo', user: 'bar') }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'throws a Symgate error when called with a user with a password and a token' do
      opts = { account: 'foo', user: 'bar', password: 'baz', token: 'nuts' }
      expect { client_of_type(Symgate::Client, opts) }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'throws a Symgate error when called with a key and password' do
      opts = { account: 'foo', key: 'bar', password: 'baz' }
      expect { client_of_type(Symgate::Client, opts) }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'creates a valid client when called with a user and password' do
      opts = { account: 'foo', user: 'bar', password: 'baz' }
      client = nil
      expect { client = client_of_type(Symgate::Client, opts) }.not_to raise_error
      expect(client.savon_client).to be_a(Savon::Client)
    end

    it 'creates a valid client when called with a user and token' do
      opts = { account: 'foo', user: 'bar', token: 'baz' }
      client = nil
      expect { client = client_of_type(Symgate::Client, opts) }.not_to raise_error
      expect(client.savon_client).to be_a(Savon::Client)
    end

    it 'creates a valid client when called with an account, key, and user to impersonate' do
      opts = { account: 'foo', key: 'bar', impersonate: 'group/user' }
      client = nil
      expect { client = client_of_type(Symgate::Client, opts) }.not_to raise_error
      expect(client.impersonate).to eq('group/user')
    end

    it 'throws a Symgate error when impersonation is requested without an account' do
      expect { Symgate::Client.new(key: 'bar', impersonate: 'group/user') }.to raise_error(
        Symgate::Error, 'No account specified'
      )
    end

    it 'throws a Symgate error when impersonation is requested without a key or user' do
      expect { client_of_type(Symgate::Client, account: 'foo', impersonate: 'group/user') }.to raise_error(
        Symgate::Error, 'No key or user specified'
      )
    end

    it 'creates a valid client when called with a user, password, and user to impersonate' do
      opts = { account: 'foo', user: 'bar', password: 'baz', impersonate: 'group/other' }
      client = nil
      expect { client = client_of_type(Symgate::Client, opts) }.not_to raise_error
      expect(client.impersonate).to eq('group/other')
    end

    it 'creates a valid client when called with a user, token, and user to impersonate' do
      opts = { account: 'foo', user: 'bar', token: 'baz', impersonate: 'group/other' }
      client = nil
      expect { client = client_of_type(Symgate::Client, opts) }.not_to raise_error
      expect(client.impersonate).to eq('group/other')
    end

    it 'throws a Symgate error when impersonation is combined with a key and a user' do
      opts = { account: 'foo', key: 'bar', user: 'baz', password: 'qux', impersonate: 'group/other' }
      expect { client_of_type(Symgate::Client, opts) }.to raise_error(
        Symgate::Error, 'Both key and user were specified'
      )
    end

    it 'throws a Symgate error when impersonation is combined with a key and a password' do
      opts = { account: 'foo', key: 'bar', password: 'baz', impersonate: 'group/user' }
      expect { client_of_type(Symgate::Client, opts) }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end

    it 'throws a Symgate error when impersonation is combined with a key and a token' do
      opts = { account: 'foo', key: 'bar', token: 'baz', impersonate: 'group/user' }
      expect { client_of_type(Symgate::Client, opts) }.to raise_error(
        Symgate::Error, 'You must supply one of key, password or token'
      )
    end
  end

  describe '#savon_creds' do
    before(:each) do
      Symgate::Client.send(:public, :savon_creds)
    end

    it 'returns a hash' do
      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect(client.savon_creds).to be_a(Hash)
    end

    it 'adds the account and key to the hash, when specified' do
      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect(client.savon_creds).to eq(%s(auth:creds) => { %s(auth:account) => 'foo',
                                                           %s(auth:key) => 'bar' })
    end

    it 'adds the user and password to the hash, when specified' do
      client = client_of_type(Symgate::Client, account: 'foo', user: 'bar', password: 'baz')
      expect(client.savon_creds).to eq(%s(auth:creds) => { %s(auth:account) => 'foo',
                                                           %s(auth:user) => {
                                                             %s(auth:id) => 'bar',
                                                             %s(auth:password) => 'baz'
                                                           } })
    end

    it 'adds the account, key, and impersonated user to the hash, when specified' do
      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar', impersonate: 'group/user')
      expect(client.savon_creds).to eq(%s(auth:creds) => { %s(auth:account) => 'foo',
                                                           %s(auth:key) => 'bar',
                                                           %s(auth:impersonate) => 'group/user' })
    end

    it 'adds the user, password, and impersonated user to the hash, when specified' do
      client = client_of_type(Symgate::Client, account: 'foo', user: 'bar', password: 'baz',
                                               impersonate: 'group/other')
      expect(client.savon_creds).to eq(%s(auth:creds) => { %s(auth:account) => 'foo',
                                                           %s(auth:user) => {
                                                             %s(auth:id) => 'bar',
                                                             %s(auth:password) => 'baz'
                                                           },
                                                           %s(auth:impersonate) => 'group/other' })
    end

    it 'adds the user, token, and impersonated user to the hash, when specified' do
      client = client_of_type(Symgate::Client, account: 'foo', user: 'bar', token: 'baz',
                                               impersonate: 'group/other')
      expect(client.savon_creds).to eq(%s(auth:creds) => { %s(auth:account) => 'foo',
                                                           %s(auth:user) => {
                                                             %s(auth:id) => 'bar',
                                                             %s(auth:authtoken) => 'baz'
                                                           },
                                                           %s(auth:impersonate) => 'group/other' })
    end

    it 'adds the user and token to the hash, when specified' do
      client = client_of_type(Symgate::Client, account: 'foo', user: 'bar', token: 'baz')
      expect(client.savon_creds).to eq(%s(auth:creds) => { %s(auth:account) => 'foo',
                                                           %s(auth:user) => {
                                                             %s(auth:id) => 'bar',
                                                             %s(auth:authtoken) => 'baz'
                                                           } })
    end
  end

  describe '#savon_request' do
    before(:each) do
      Symgate::Client.send(:public, :savon_request)
    end

    it 'sends the impersonated user with the account and key' do
      savon.expects(:enumerate_groups)
           .with(message: { %s(auth:creds) => { %s(auth:account) => 'foo',
                                                %s(auth:key) => 'bar',
                                                %s(auth:impersonate) => 'group/user' } })
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_empty.xml'))

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar', impersonate: 'group/user')
      expect { client.savon_request(:enumerate_groups) }.not_to raise_error
    end

    it 'sends the impersonated user with the account, user, and password' do
      savon.expects(:enumerate_groups)
           .with(message: { %s(auth:creds) => { %s(auth:account) => 'foo',
                                                %s(auth:user) => {
                                                  %s(auth:id) => 'group/admin',
                                                  %s(auth:password) => 'baz'
                                                },
                                                %s(auth:impersonate) => 'group/user' } })
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_empty.xml'))

      client = client_of_type(Symgate::Client, account: 'foo', user: 'group/admin', password: 'baz',
                                               impersonate: 'group/user')
      expect { client.savon_request(:enumerate_groups) }.not_to raise_error
    end

    it 'sends the impersonated user with the account, user, and token' do
      savon.expects(:enumerate_groups)
           .with(message: { %s(auth:creds) => { %s(auth:account) => 'foo',
                                                %s(auth:user) => {
                                                  %s(auth:id) => 'group/admin',
                                                  %s(auth:authtoken) => 'baz'
                                                },
                                                %s(auth:impersonate) => 'group/user' } })
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_empty.xml'))

      client = client_of_type(Symgate::Client, account: 'foo', user: 'group/admin', token: 'baz',
                                               impersonate: 'group/user')
      expect { client.savon_request(:enumerate_groups) }.not_to raise_error
    end

    it 'fails when an unknown method is called' do
      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect { client.savon_request(:make_pancakes) }.to raise_error(Savon::UnknownOperationError)
    end

    it 'returns access denied when called with incorrect credentials' do
      savon.expects(:enumerate_groups)
           .with(message: { %s(auth:creds) => { %s(auth:account) => 'foo',
                                                %s(auth:key) => 'bar' } })
           .returns(File.read('test/spec/fixtures/xml/access_denied.xml'))

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      response_xml = File.read('test/spec/fixtures/xml/access_denied.xml')
      expect { |b| client.savon_request(:enumerate_groups, &b) }.to raise_error do |e|
        expect(e).to be_a(Symgate::Error)
        expect(e.message).to include('Access denied')
        expect(e.fault_string).to eq('Access denied')
        expect(e.detail).to be_nil
        expect(e.original_error).to be_a(Savon::SOAPFault)
        expect(e.request_xml).to include('foo')
        expect(e.response_xml).to eq(response_xml)
      end
    end

    it 'retries when the symboliser reports that data is required' do
      message = { %s(auth:creds) => { %s(auth:account) => 'foo',
                                      %s(auth:key) => 'bar' } }
      savon.expects(:enumerate_groups)
           .with(message: message)
           .returns(File.read('test/spec/fixtures/xml/fault_data_required.xml'))
      savon.expects(:enumerate_groups)
           .with(message: message)
           .returns(File.read('test/spec/fixtures/xml/enumerate_groups_empty.xml'))

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect { client.savon_request(:enumerate_groups) }.not_to raise_error
    end

    it 'exposes the SOAP fault detail separately from the fault string' do
      response_xml = File.read('test/spec/fixtures/xml/fault_with_detail.xml')
      savon.expects(:enumerate_groups)
           .with(message: { %s(auth:creds) => { %s(auth:account) => 'foo',
                                                %s(auth:key) => 'bar' } })
           .returns(response_xml)

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect { |b| client.savon_request(:enumerate_groups, &b) }.to raise_error do |e|
        expect(e.fault_string).to eq('Processing failed')
        expect(e.detail).to eq('Provided credentials have expired')
        expect(e.message).to include('Provided credentials have expired')
        expect(e.response_xml).to eq(response_xml)
      end
    end

    it 'does not retry an expired credential fault' do
      response_xml = File.read('test/spec/fixtures/xml/fault_with_detail.xml')
      savon.expects(:enumerate_groups)
           .with(message: { %s(auth:creds) => { %s(auth:account) => 'foo',
                                                %s(auth:key) => 'bar' } })
           .returns(response_xml)

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect { client.savon_request(:enumerate_groups) }.to raise_error do |e|
        expect(e.fault_string).to eq('Processing failed')
        expect(e.detail).to eq('Provided credentials have expired')
        expect(e.response_xml).to eq(response_xml)
      end
    end

    it 'raises the last data required fault after three attempts' do
      fault_xml = File.read('test/spec/fixtures/xml/fault_data_required.xml')
      last_fault_xml = fault_xml.sub('</faultstring>', '</faultstring><detail>final attempt</detail>')
      message = { %s(auth:creds) => { %s(auth:account) => 'foo', %s(auth:key) => 'bar' } }

      2.times do
        savon.expects(:enumerate_groups).with(message: message).returns(fault_xml)
      end
      savon.expects(:enumerate_groups).with(message: message).returns(last_fault_xml)

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      expect { client.savon_request(:enumerate_groups) }.to raise_error do |e|
        expect(e).to be_a(Symgate::Error)
        expect(e.fault_string).to eq('Data required for operation')
        expect(e.detail).to eq('final attempt')
        expect(e.original_error).to be_a(Savon::SOAPFault)
        expect(e.request_xml).to include('foo')
        expect(e.response_xml).to eq(last_fault_xml)
      end
    end

    it 'does not retry a data required fault when the attempt limit is 1' do
      fault_xml = File.read('test/spec/fixtures/xml/fault_data_required.xml')
      message = { %s(auth:creds) => { %s(auth:account) => 'foo', %s(auth:key) => 'bar' } }
      savon.expects(:enumerate_groups).with(message: message).returns(fault_xml)

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      client.data_required_error_retries = 1

      expect { client.savon_request(:enumerate_groups) }.to raise_error do |e|
        expect(e.fault_string).to eq('Data required for operation')
        expect(e.response_xml).to eq(fault_xml)
      end
    end

    it 'does not retry an unreadable fault' do
      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      fault = Savon::SOAPFault.allocate
      def fault.to_hash
        raise StandardError, 'unparseable'
      end

      def fault.message
        'SOAP request failed'
      end

      expect(client.savon_client).to receive(:call).once.and_raise(fault)

      expect { client.savon_request(:enumerate_groups) }.to raise_error do |e|
        expect(e).to be_a(Symgate::Error)
        expect(e.message).to eq('SOAP request failed')
        expect(e.original_error).to equal(fault)
      end
    end

    it 'retries a data required fault and returns the later response' do
      fault_xml = File.read('test/spec/fixtures/xml/fault_data_required.xml')
      success_xml = File.read('test/spec/fixtures/xml/enumerate_groups_empty.xml')
      message = { %s(auth:creds) => { %s(auth:account) => 'foo', %s(auth:key) => 'bar' } }

      2.times do
        savon.expects(:enumerate_groups).with(message: message).returns(fault_xml)
      end
      savon.expects(:enumerate_groups).with(message: message).returns(success_xml)

      client = client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      response = client.savon_request(:enumerate_groups)

      expect(response).to be_a(Savon::Response)
      expect(response.xml).to eq(success_xml)
    end

    it 'installs one request observer' do
      client_of_type(Symgate::Client, account: 'foo', key: 'bar')
      client_of_type(Symgate::Client, account: 'foo', key: 'bar')

      observers = Savon.observers.select { |observer| observer.is_a?(Symgate::RequestObserver) }
      expect(observers.length).to eq(1)
    end
  end

  describe '#data_required_fault?' do
    let(:client) { client_of_type(Symgate::Client, account: 'foo', key: 'bar') }

    it 'matches the symboliser data required fault' do
      payload = { fault: { faultstring: 'Data required for operation' } }
      fault = Object.new
      fault.define_singleton_method(:to_hash) { payload }

      expect(client.send(:data_required_fault?, fault)).to eq(true)
    end

    it 'does not match a different fault' do
      payload = { fault: { faultstring: 'Access denied' } }
      fault = Object.new
      fault.define_singleton_method(:to_hash) { payload }

      expect(client.send(:data_required_fault?, fault)).to eq(false)
    end

    it 'does not match an unreadable fault' do
      fault = Object.new
      def fault.to_hash
        raise StandardError, 'unparseable'
      end

      expect(client.send(:data_required_fault?, fault)).to eq(false)
    end
  end

  describe '#savon_array' do
    it 'returns an empty array when the hash does not contain the key' do
      expect(Symgate::Client.savon_array({ bar: 'foo' }, :foo)).to match_array([])
    end

    it 'returns an array with one item when the hash item is a non-array' do
      expect(Symgate::Client.savon_array({ foo: 'bar' }, :foo)).to match_array(%w[bar])
    end

    it 'returns an array with multiple items when the hash item is an array' do
      expect(Symgate::Client.savon_array({ foo: %w[bar baz] }, :foo)).to match_array(%w[bar baz])
    end
  end
end
