require 'symgate/client'

module Symgate
  module Auth
    # client for the Symgate authentication system
    class Client < Symgate::Client
      # returns a list of groups for the specified symgate account
      def enumerate_groups
        Symgate::Client.savon_array(
          savon_request(:enumerate_groups).body[:enumerate_groups_response],
          :groupid
        )
      end
    end
  end
end
