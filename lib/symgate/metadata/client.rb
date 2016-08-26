require 'symgate/client'
require 'symgate/error'
require 'symgate/metadata/data_item'

# rubocop:disable Style/AccessorMethodName

module Symgate
  module Metadata
    # client for the Symgate metadata system
    class Client < Symgate::Client
      # Gets metadata visible to the current user.
      #
      # If the 'scope' option is specified, this will list only the metadata
      # defined at a particular scope. Otherwise it will list metadata items
      # visible, with user metadata replacing group metadata and so on.
      #
      # If the 'keys' option is specified, this will list only the metadata
      # matching the list of keys supplied.
      #
      # The 'key' option is also provided as a convenience, which works as above
      # for a single item.
      def get_metadata(opts = {})
        o = opts
        parse_get_metadata_opts o
        o[:key] = o.delete(:keys) if o.include? :keys

        resp = savon_request(:get_metadata) { |soap| soap.message(o) }

        Symgate::Client.savon_array(
          resp.body[:get_metadata_response],
          :data_item
        ).map { |item| Symgate::Metadata::DataItem.from_soap(item) }
      end

      # Creates one or more metadata items, overwriting any that match the key
      # and scope specified within the DataItem object. Supply either a single
      # item or an array of items.
      def set_metadata(items)
        i = [items].flatten

        check_array_for_type(i, Symgate::Metadata::DataItem)
        raise Symgate::Error, 'No items supplied' if i.empty?

        savon_request(:set_metadata) { |soap| soap.message('auth:data_item': i.map(&:to_soap)) }
      end

      # Destroys one or more metadata items on the specified scope, specified by
      # their key(s). Specify a valid scope and a single string, or an array of
      # strings.
      def destroy_metadata(scope, keys)
        k = [keys].flatten
        check_array_for_type(k, String)
        raise Symgate::Error, 'No keys supplied' if k.empty?

        savon_request(:destroy_metadata) { |soap| soap.message(scope: scope, key: k) }
      end

      private

      def parse_get_metadata_opts(opts)
        arrayize_get_key_option(opts)
        check_get_keys_array(opts)
        check_for_unknown_get_opts(opts)
      end

      def arrayize_get_key_option(opts)
        if opts.include? :key
          raise Symgate::Error, 'Supply only one of "key" or "keys"' if opts.include? :keys
          opts[:keys] = [opts[:key]]
          opts.delete(:key)
        end
      end

      def check_get_keys_array(opts)
        if opts.include? :keys
          raise Symgate::Error, '"keys" must be an array' unless opts[:keys].is_a? Array
          check_array_for_type(opts[:keys], String)
        end
      end

      def check_for_unknown_get_opts(opts)
        opts.keys.each do |k|
          raise Symgate::Error, "Unknown option: #{k}" unless %i(keys scope).include? k
        end
      end

      def check_array_for_type(ary, type_name)
        ary.each do |item|
          unless item.is_a? type_name
            raise Symgate::Error, "'#{item.inspect}' is not a #{type_name.name}"
          end
        end
      end
    end
  end
end
