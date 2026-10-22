require 'savon'

module Symgate
  # Defines a symgate-specific error so this can be caught by the caller
  class Error < StandardError
    attr_reader :original_error, :detail, :fault_string, :request_xml, :response_xml

    # Initialises a symgate error from either a string or a Savon error
    def initialize(message)
      super(message)
    end

    def self.from_savon(error, request_xml = nil)
      symgate_error = new(message_from_savon_error(error))
      symgate_error.original_error = error
      symgate_error.instance_variable_set(:@request_xml, request_xml)
      symgate_error.instance_variable_set(:@response_xml, response_xml_from(error))
      symgate_error
    end

    def original_error=(error)
      @original_error = error
      assign_fault(error)
    end

    def self.message_from_savon_error(error)
      "#{error.message}. #{error.to_hash[:fault][:detail]}"
    rescue StandardError
      error.message
    end

    def self.response_xml_from(error)
      xml = error.xml if error.respond_to?(:xml)
      return xml unless xml.nil?

      http = error.http if error.respond_to?(:http)
      return nil if http.nil?

      http.body if http.respond_to?(:body)
    rescue StandardError
      nil
    end

    private

    def assign_fault(error)
      fault = fault_from(error)
      return unless fault

      @fault_string = fault[:faultstring]
      @detail = fault[:detail]
    end

    def fault_from(error)
      return nil unless error.respond_to?(:to_hash)

      hash = error.to_hash
      fault = hash[:fault] if hash.is_a?(Hash)
      fault if fault.is_a?(Hash)
    rescue StandardError
      nil
    end
  end
end
