require 'symgate/client'
require 'symgate/auth/user'

module Symgate
  module Auth
    # client for the Symgate authentication system
    class Client < Symgate::Client
      # returns a list of groups for the current symgate account
      def enumerate_groups
        Symgate::Client.savon_array(
          savon_request(:enumerate_groups).body[:enumerate_groups_response],
          :groupid
        )
      end

      # creates a new group
      def create_group(group_id)
        savon_request(:create_group) do |soap|
          soap.message(groupid: group_id)
        end
      end

      # destroys an existing group
      def destroy_group(group_id)
        savon_request(:destroy_group) do |soap|
          soap.message(groupid: group_id)
        end
      end

      # renames a group
      def rename_group(old_group_id, new_group_id)
        savon_request(:rename_group) do |soap|
          soap.message(old_groupid: old_group_id, new_groupid: new_group_id)
        end
      end

      # returns a list of users for the specified group
      def enumerate_users(group_id)
        response = savon_request(:enumerate_users) do |soap|
          soap.message(groupid: group_id)
        end

        Symgate::Client.savon_array(
          response.body[:enumerate_users_response],
          :user
        ).map { |u| Symgate::Auth::User.from_soap(u) }
      end

      # creates a new user from a Symgate::Auth::User, with the specified password
      def create_user(user, password)
        savon_request(:create_user) do |soap|
          soap.message(password: password)
          user.to_soap(soap[:message])
        end
      end

      # updates a user (sets the is_group_admin member)
      def update_user(user)
        savon_request(:update_user) do |soap|
          soap.message({})
          user.to_soap(soap[:message])
        end
      end

      # renames a user (must be within the same group)
      def rename_user(old_user_id, new_user_id)
        savon_request(:rename_user) do |soap|
          soap.message(old_user_id: old_user_id, new_user_id: new_user_id)
        end
      end

      # moves a user between groups
      def move_user(old_user_id, new_user_id)
        savon_request(:move_user) do |soap|
          soap.message(old_user_id: old_user_id, new_user_id: new_user_id)
        end
      end

      # sets the password for a user
      def set_user_password(user_id, password)
        savon_request(:set_user_password) do |soap|
          soap.message(userid: user_id, password: password)
        end
      end

      # destroys a user
      def destroy_user(user_id)
        savon_request(:destroy_user) do |soap|
          soap.message(userid: user_id)
        end
      end
    end
  end
end
