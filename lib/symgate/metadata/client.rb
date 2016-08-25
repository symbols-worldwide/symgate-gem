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
      end

      # Destroys one or more metadata items on the specified scope, specified by
      # their key(s). Specify a valid scope and a single string, or an array of
      # strings.
      def destroy_metadata(scope, keys)
      end

      private

      def parse_get_metadata_opts(opts)
        arrayize_key_option(opts)
        check_keys_array_for_non_strings(opts)
        check_for_unknown_options_to_get_metata(opts)
      end

      def arrayize_key_option(opts)
        if opts.include? :key
          raise Symgate::Error, 'Supply only one of "key" or "keys"' if opts.include? :keys
          opts[:keys] = [opts[:key]]
          opts.delete(:key)
        end
      end

      def check_keys_array_for_non_strings(opts)
        if opts.include? :keys
          raise Symgate::Error, '"keys" must be an array' unless opts[:keys].is_a? Array
          opts[:keys].each do |k|
            unless k.is_a? String
              raise Symgate::Error, "Expected key type of String but got #{k.class}"
            end
          end
        end
      end

      def check_for_unknown_options_to_get_metata(opts)
        opts.keys.each do |k|
          raise Symgate::Error, "Unknown option: #{k}" unless %i(keys scope).include? k
        end
      end
    end
  end
end
