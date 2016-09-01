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
        savon_request(:create_group, returns_error_string: true) do |soap|
          soap.message(groupid: group_id)
        end
      end

      # destroys an existing group
      def destroy_group(group_id)
        savon_request(:destroy_group, returns_error_string: true) do |soap|
          soap.message(groupid: group_id)
        end
      end

      # renames a group
      def rename_group(old_group_id, new_group_id)
        savon_request(:rename_group, returns_error_string: true) do |soap|
          soap.message(old_groupid: old_group_id, new_groupid: new_group_id)
        end
      end

      # returns a list of users for the specified group
      def enumerate_users(group_id)
        resp = savon_request(:enumerate_users) { |soap| soap.message(groupid: group_id) }

        Symgate::Client.savon_array(
          resp.body[:enumerate_users_response],
          :user,
          Symgate::Auth::User
        )
      end

      # creates a new user from a Symgate::Auth::User, with the specified password
      def create_user(user, password)
        savon_request(:create_user, returns_error_string: true) do |soap|
          soap.message(password: password)
          user.to_soap(soap[:message])
        end
      end

      # updates a user (sets the is_group_admin member)
      def update_user(user)
        savon_request(:update_user, returns_error_string: true) do |soap|
          soap.message({})
          user.to_soap(soap[:message])
        end
      end

      # renames a user (must be within the same group)
      def rename_user(old_user_id, new_user_id)
        savon_request(:rename_user, returns_error_string: true) do |soap|
          soap.message(old_user_id: old_user_id, new_user_id: new_user_id)
        end
      end

      # moves a user between groups
      def move_user(old_user_id, new_user_id)
        savon_request(:move_user, returns_error_string: true) do |soap|
          soap.message(old_user_id: old_user_id, new_user_id: new_user_id)
        end
      end

      # sets the password for a user
      def set_user_password(user_id, password)
        savon_request(:set_user_password, returns_error_string: true) do |soap|
          soap.message(userid: user_id, password: password)
        end
      end

      # destroys a user
      def destroy_user(user_id)
        savon_request(:destroy_user, returns_error_string: true) do |soap|
          soap.message(userid: user_id)
        end
      end

      # authenticates a user and returns a token, optionally with a user to impersonate
      def authenticate(user_to_impersonate = nil)
        r = savon_request(:authenticate) do |soap|
          soap.message(userid: user_to_impersonate) if user_to_impersonate
        end.body[:authenticate_response]

        r ? r[:authtoken] : nil
      end

      # adds a language to the specified group and returns 'OK' if successful or
      # 'Exists' if the language is already assigned to the account
      def add_group_language(group, language)
        savon_request(:add_group_language) do |soap|
          soap.message(groupid: group, language: language)
        end.body[:add_group_language_response]
      end

      # removes a language from the specified group and returns 'OK' if successful or
      # 'NotExist' if the language is not assigned to the account
      def remove_group_language(group, language)
        savon_request(:remove_group_language) do |soap|
          soap.message(groupid: group, language: language)
        end.body[:remove_group_language_response]
      end

      # lists the languages assigned to a group
      def enumerate_group_languages(group_id)
        resp = savon_request(:enumerate_group_languages) { |soap| soap.message(groupid: group_id) }

        Symgate::Client.savon_array(
          resp.body[:enumerate_group_languages_response],
          :language
        )
      end

      # queries whether a language is available for a group
      def query_group_language(group_id, language)
        savon_request(:query_group_language) do |soap|
          soap.message(groupid: group_id, language: language)
        end.body[:query_group_language_response]
      end

      # lists the language for the currently authenticated user
      def enumerate_languages
        resp = savon_request(:enumerate_languages)

        Symgate::Client.savon_array(
          resp.body[:enumerate_languages_response],
          :language
        )
      end

      # queries whether a language is available for the currently authenticated user
      def query_language(language)
        savon_request(:query_language) { |soap| soap.message(language: language) }
          .body[:query_language_response]
      end
    end
  end
end
