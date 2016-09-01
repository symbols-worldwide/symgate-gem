require 'symgate/type'

module Symgate
  module Auth
    # defines a symgate user
    class User < Symgate::Type
      def initialize(opts = {})
        super(opts)
        @is_group_admin = opts[:is_group_admin] || false
      end

      def self.from_soap(hash)
        Symgate::Auth::User.new(
          user_id: hash[:@id],
          is_group_admin: hash[:@is_group_admin] == 'true'
        )
      end

      def to_soap(hash)
        hash[:'auth:user'] = ''
        hash[:attributes!] = {} unless hash.include? :attributes!
        hash[:attributes!][:'auth:user'] = { id: @user_id }
        hash[:attributes!][:'auth:user'][:isGroupAdmin] = @is_group_admin if @is_group_admin
      end

      def to_s
        @user_id + (@is_group_admin ? '(admin)' : '')
      end

      protected

      def attributes
        %i(user_id is_group_admin)
      end
    end
  end
end
