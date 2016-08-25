require 'symgate/client'
require 'symgate/auth/user'

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
    end
  end
end
