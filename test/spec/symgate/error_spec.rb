require_relative '../spec_helper.rb'

require 'symgate/error'

# Stand-in for the parts of Savon::SOAPFault used by Symgate::Error.
class FaultDouble
  attr_reader :message, :http

  def initialize(message:, hash: nil, xml: nil, http: nil, hash_error: false, xml_error: false)
    @message = message
    @hash = hash
    @xml = xml
    @http = http
    @hash_error = hash_error
    @xml_error = xml_error
  end

  def to_hash
    raise StandardError, 'unparseable fault' if @hash_error

    @hash
  end

  def xml
    raise StandardError, 'missing response' if @xml_error

    @xml
  end
end

RSpec.describe(Symgate::Error) do
  describe '.from_savon' do
    it 'exposes the fault string, detail, original error, and response XML' do
      response_xml = '<detail>Provided credentials have expired</detail>'
      fault = FaultDouble.new(
        message: '(SOAP-ENV:Client) Processing failed',
        hash: {
          fault: {
            faultstring: 'Processing failed',
            detail: 'Provided credentials have expired'
          }
        },
        xml: response_xml
      )

      error = Symgate::Error.from_savon(fault, '<request/>')

      expect(error).to be_a(Symgate::Error)
      expect(error.message).to eq(
        '(SOAP-ENV:Client) Processing failed. Provided credentials have expired'
      )
      expect(error.fault_string).to eq('Processing failed')
      expect(error.detail).to eq('Provided credentials have expired')
      expect(error.original_error).to equal(fault)
      expect(error.request_xml).to eq('<request/>')
      expect(error.response_xml).to eq(response_xml)
    end

    it 'keeps the original message when the fault hash is incomplete' do
      fault = FaultDouble.new(message: 'SOAP request failed', hash: {})

      error = Symgate::Error.from_savon(fault)

      expect(error.message).to eq('SOAP request failed')
      expect(error.fault_string).to be_nil
      expect(error.detail).to be_nil
      expect(error.original_error).to equal(fault)
      expect(error.request_xml).to be_nil
      expect(error.response_xml).to be_nil
    end

    it 'keeps the original message when fault parsing fails' do
      http = Struct.new(:body).new('<response/>')
      fault = FaultDouble.new(message: 'SOAP request failed', hash_error: true, http: http)

      error = Symgate::Error.from_savon(fault, '<request/>')

      expect(error.message).to eq('SOAP request failed')
      expect(error.fault_string).to be_nil
      expect(error.detail).to be_nil
      expect(error.original_error).to equal(fault)
      expect(error.request_xml).to eq('<request/>')
      expect(error.response_xml).to eq('<response/>')
    end

    it 'returns nil response XML when the response cannot be read' do
      fault = FaultDouble.new(
        message: 'SOAP request failed',
        hash: { fault: { faultstring: 'Processing failed' } },
        xml_error: true
      )

      error = Symgate::Error.from_savon(fault)

      expect(error.fault_string).to eq('Processing failed')
      expect(error.response_xml).to be_nil
    end

    it 'ignores a fault value that is not a hash' do
      fault = FaultDouble.new(message: 'SOAP request failed', hash: { fault: 'Processing failed' })

      error = Symgate::Error.from_savon(fault)

      expect(error.fault_string).to be_nil
      expect(error.detail).to be_nil
    end

    it 'ignores a parsed body that is not a hash' do
      fault = FaultDouble.new(message: 'SOAP request failed', hash: 'not a hash')

      error = Symgate::Error.from_savon(fault)

      expect(error.fault_string).to be_nil
      expect(error.detail).to be_nil
    end

    it 'ignores an error that cannot be parsed as a fault' do
      fault = Object.new
      def fault.message
        'SOAP request failed'
      end

      error = Symgate::Error.from_savon(fault)

      expect(error.message).to eq('SOAP request failed')
      expect(error.fault_string).to be_nil
      expect(error.detail).to be_nil
      expect(error.original_error).to equal(fault)
    end
  end

  describe '.response_xml_from' do
    it 'returns nil when the HTTP response has no body' do
      http = Object.new
      fault = FaultDouble.new(message: 'SOAP request failed', http: http)

      expect(Symgate::Error.response_xml_from(fault)).to be_nil
    end
  end

  describe 'string errors' do
    it 'has no SOAP diagnostics' do
      error = Symgate::Error.new('No account specified')

      expect(error.message).to eq('No account specified')
      expect(error.fault_string).to be_nil
      expect(error.detail).to be_nil
      expect(error.original_error).to be_nil
      expect(error.request_xml).to be_nil
      expect(error.response_xml).to be_nil
    end
  end
end
