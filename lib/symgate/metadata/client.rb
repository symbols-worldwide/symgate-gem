require 'symgate/client'
require 'symgate/error'
require 'symgate/metadata/data_item'

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
          :data_item,
          Symgate::Metadata::DataItem
        )
      end

      # Creates one or more metadata items, overwriting any that match the key
      # and scope specified within the DataItem object. Supply either a single
      # item or an array of items.
      def set_metadata(items)
        i = [items].flatten

        check_array_for_type(i, Symgate::Metadata::DataItem)
        raise Symgate::Error, 'No items supplied' if i.empty?

        savon_request(:set_metadata, returns_error_string: true) do |soap|
          soap.message(%s(auth:data_item) => i.map(&:to_soap))
        end
      end

      # Destroys one or more metadata items on the specified scope, specified by
      # their key(s). Specify a valid scope and a single string, or an array of
      # strings.
      def destroy_metadata(scope, keys)
        k = [keys].flatten
        check_array_for_type(k, String)
        raise Symgate::Error, 'No keys supplied' if k.empty?

        savon_request(:destroy_metadata, returns_error_string: true) do |soap|
          soap.message(scope: scope, key: k)
        end
      end

      private

      def parse_get_metadata_opts(opts)
        arrayize_option(:key, :keys, opts)
        check_option_is_array_of(String, :keys, opts)
        check_for_unknown_opts(%i[keys scope], opts)
      end
    end
  end
end
