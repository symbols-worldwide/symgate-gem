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

    # returns an array from 0 or more items when an array is expected.
    # (savon returns a single value for things that can be a sequence of multiple objects)
    # expects a hash, and a key for the array within that hash
    def self.savon_array(hash, key)
      if hash && hash.include?(key)
        [hash[key]].flatten
      else
        []
      end
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

    # builds a credentials object - required for all requests
    def savon_creds
      creds = { 'auth:account': @account }
      creds[:'auth:key'] = @key if @key
      creds[:'auth:user'] = savon_user if @user

      creds
    end

    def savon_user
      user = { 'auth:id': @user }
      user[:'auth:password'] = @password if @password
      user[:'auth:authtoken'] = @token if @token

      user
    end

    # sends a request to the server and yields a soap block for defining the
    # message body
    def savon_request(method)
      @savon_client.call(method) do |soap|
        yield soap if block_given?
        soap.message({}) if soap[:message].nil?
        soap[:message].merge!(savon_creds)
      end
    rescue Savon::SOAPFault => e
      raise Symgate::Error.from_savon(e)
    end
  end
end
