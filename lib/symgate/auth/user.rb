module Symgate
  module Auth
    # defines a symgate user
    class User
      attr_accessor :user_id, :is_group_admin

      def initialize(params = {})
        @user_id = params[:user_id]
        @is_group_admin = params[:is_group_admin] || false
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

      def ==(other)
        @user_id == other.user_id && @is_group_admin == other.is_group_admin
      end

      def operator=(other)
        @user_id = other.user_id
        @is_group_admin = other.is_group_admin
      end
    end
  end
end
