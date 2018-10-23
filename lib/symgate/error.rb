require 'savon'

module Symgate
  # Defines a symgate-specific error so this can be caught by the caller
  class Error < StandardError
    attr_reader :original_error, :detail

    # Initialises a symgate error from either a string or a savon error
    def initialize(message)
      super(message)
    end

    def self.from_savon(error)
      e = Symgate::Error.new(message_from_savon_error(error))

      e.original_error = error
      e
    end

    def original_error=(error)
      @original_error = error
      @detail = error.to_hash[:fault][:detail]
    end

    def self.message_from_savon_error(error)
      "#{error.message}. #{error.to_hash[:fault][:detail]}"
    rescue StandardError
      # :nocov:
      error.message
      # :nocov:
    end
  end
end
