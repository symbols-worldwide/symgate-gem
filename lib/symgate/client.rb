require 'savon'
require 'symgate/error'
require 'symgate/namespaces'

module Symgate
  # A generic client for the Symgate API.
  # See the WSDL for full documentation
  class Client
    attr_accessor :wsdl, :endpoint, :user, :password, :token, :account, :key, :savon_opts,
                  :data_required_error_retries
    attr_reader :savon_client

    # Constructs a new client with the provided options
    def initialize(opts = {})
      @wsdl = 'https://ws.widgitonline.com/schema/symboliser.wsdl'
      @endpoint = 'https://ws.widgitonline.com/'
      @savon_opts = {}
      @data_required_error_retries = 3
      opts.each { |k, v| instance_variable_set("@#{k}", v) }

      validate_client_options
      create_savon_client
    end

    # returns an array from 0 or more items when an array is expected.
    # (savon returns a single value for things that can be a sequence of multiple objects)
    # expects a hash, and a key for the array within that hash.
    # if classname is specified, the method will return an array of objects initialised
    # by the hash contents
    def self.savon_array(hash, key, classname = nil)
      if hash && hash.include?(key)
        [hash[key]].flatten
      else
        []
      end.map { |v| classname ? classname.from_soap(v) : v }
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
      raise Symgate::Error, 'You must supply one of key, password or token' unless
          [@key, @password, @token].one?
    end

    def create_savon_client
      @savon_client = Savon.client(savon_opts.merge(wsdl: @wsdl, endpoint: @endpoint)) do
        endpoint(@endpoint) if @endpoint
        namespaces(Symgate::NAMESPACES)
      end
    end

    # builds a credentials object - required for all requests
    def savon_creds
      creds = { %s(auth:account) => @account }
      creds[:'auth:key'] = @key if @key
      creds[:'auth:user'] = savon_user if @user

      { %s(auth:creds) => creds }
    end

    def savon_user
      user = { %s(auth:id) => @user }
      user[:'auth:password'] = @password if @password
      user[:'auth:authtoken'] = @token if @token

      user
    end

    # sends a request to the server and yields a soap block for defining the
    # message body
    def savon_request(method, opts = {})
      attempts = 0

      begin
        attempts += 1

        r = @savon_client.call(method) do |soap|
          yield soap if block_given?
          soap.message({}) if soap[:message].nil?
          soap[:message].merge!(savon_creds)
        end

        raise_error_on_string_response(r, "#{method}_response".to_sym) if opts[:returns_error_string]

        r
      rescue Savon::SOAPFault => e
        # Allow a configurable number of retries for a 'Data required for operation' error. This is because the
        # symboliser occasionally throw this error when it shouldn't and succeeds on retry. It's not ideal that we have
        # to rely on the fault string, however.
        if attempts < @data_required_error_retries && e.to_hash[:fault][:faultstring] == 'Data required for operation'
          retry
        end

        raise Symgate::Error.from_savon(e)
      end
    end

    def raise_error_on_string_response(response, response_type)
      e = response.body[response_type]
      raise Symgate::Error, e unless e.to_s == ''
    end

    def arrayize_option(singular, plural, opts)
      return unless opts.include? singular # else nothing to do
      raise Symgate::Error, "Options can't include both #{singular} and #{plural}" if
          opts.include? plural

      opts[plural] = [opts[singular]]
      opts.delete(singular)
    end

    def check_option_is_array_of(classname, key, opts)
      return unless opts.include? key
      raise Symgate::Error, "#{key} must be an array" unless opts[key].is_a? Array
      check_array_for_type(opts[key], classname)
    end

    def check_for_unknown_opts(keys, opts)
      opts.keys.each do |k|
        raise Symgate::Error, "Unknown option: #{k}" unless keys.include? k
      end
    end

    def check_array_for_type(ary, type_name)
      raise Symgate::Error, "#{ary.class.name} is not an array" unless ary.is_a? Array

      ary.each do |item|
        unless item.is_a? type_name
          raise Symgate::Error, "'#{item.class.name}' is not a #{type_name.name}"
        end
      end
    end

    def check_for_multiple_opts(keys, opts)
      raise Symgate::Error, "Supply only one of 'match' or 'entry'" if keys.all? { |k| opts.key? k }
    end
  end
end
