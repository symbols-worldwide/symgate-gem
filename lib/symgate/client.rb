require 'savon'
require 'symgate/error'
require 'symgate/namespaces'

module Symgate
  # A generic client for the Symgate API.
  # See the WSDL for full documentation
  class Client
    attr_accessor :wsdl, :endpoint, :user, :password, :token, :account, :key
    attr_reader :savon_client

    # Constructs a new client with the provided options
    def initialize(opts = {})
      @wsdl = 'https://ws.widgit.com/schema/symboliser.wsdl'
      opts.each { |k, v| instance_variable_set("@#{k}", v) }

      validate_client_options
      create_savon_client
    end

    protected

    # ensures enough information has been passed to the client
    def validate_client_options
      validate_has_account
      validate_has_key_or_user
      validate_is_passwordy
    end

    def validate_has_account
      raise Symgate::Error, 'No account specified' if @account.nil?
    end

    def validate_has_key_or_user
      raise Symgate::Error, 'No key or user specified' if @key.nil? && @user.nil?
      raise Symgate::Error, 'Both key and user were specified' if @key && @user
    end

    def validate_is_passwordy
      unless [@key, @password, @token].one?
        raise Symgate::Error, 'You must supply one of key, password or token'
      end
    end

    def create_savon_client
      @savon_client = Savon.client(wsdl: @wsdl) do
        endpoint(@endpoint) if @endpoint
        namespaces(Symgate::NAMESPACES)
      end
    end
  end
end
