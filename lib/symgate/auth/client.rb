require 'symgate/client'
require 'symgate/auth/user'

module Symgate
  module Auth
    # client for the Symgate authentication system
    class Client < Symgate::Client
      # Returns a list of groups for the current symgate account
      #
      # ==== Returns
      #
      # An array of group ids, as strings
      #
      # ==== Supported authentication types
      #
      # * account/key
      def enumerate_groups
        Symgate::Client.savon_array(
          savon_request(:enumerate_groups).body[:enumerate_groups_response],
          :groupid
        )
      end

      # Creates a new group.
      #
      # Raises a Symgate::Error on failure
      #
      # ==== Attributes
      #
      # * +group_id+ - The ID of the new group to create (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      def create_group(group_id)
        savon_request(:create_group, returns_error_string: true) do |soap|
          soap.message(groupid: group_id)
        end
      end

      # Destroys an existing group
      #
      # *IMPORTANT*: This will permanently delete the group, along with all
      # associated users, wordlists and metadata. Can't be undone.
      #
      # Raises a Symgate::Error on failure
      #
      # ==== Attributes
      #
      # * +group_id+ - The ID of the new group to create (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      def destroy_group(group_id)
        savon_request(:destroy_group, returns_error_string: true) do |soap|
          soap.message(groupid: group_id)
        end
      end

      # Renames a group
      #
      # This will require all users to use the new group_id as part of their
      # login username in future.
      #
      # Raises a Symgate::Error on failure (e.g. the +new_group_id+ is invalid)
      #
      # ==== Attributes
      #
      # * +old_group_id+ - The ID of the group to rename (String)
      # * +new_group_id+ - The new ID for the renamed group (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      def rename_group(old_group_id, new_group_id)
        savon_request(:rename_group, returns_error_string: true) do |soap|
          soap.message(old_groupid: old_group_id, new_groupid: new_group_id)
        end
      end

      # Returns a list of users for the specified group)
      #
      # ==== Attributes
      #
      # * +group_id+ - The ID of the group (String)
      #
      # ==== Returns
      #
      # An array of Symgate::Auth::User objects
      #
      # ==== Supported authentication types
      #
      # * account/key
      def enumerate_users(group_id)
        resp = savon_request(:enumerate_users) { |soap| soap.message(groupid: group_id) }

        Symgate::Client.savon_array(
          resp.body[:enumerate_users_response],
          :user,
          Symgate::Auth::User
        )
      end

      # Creates a new user
      #
      # Raises a Symgate::Error on failure (e.g. the +user+ is invalid, or the group
      # specified in the User object does not exist)
      #
      # ==== Attributes
      #
      # * +user+ - A Symgate::Auth::User describing the new user
      # * +password+ - The password for the new user (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      # * user (with +is_group_admin+)
      def create_user(user, password)
        savon_request(:create_user, returns_error_string: true) do |soap|
          soap.message(password: password)
          user.to_soap(soap[:message])
        end
      end

      # Updates a user
      #
      # Currently this can only be used to set the +is_group_admin+ member of
      # the +user+ object
      #
      # ==== Attributes
      #
      # * +user+ - The updated Symgate::Auth::User object
      #
      # ==== Supported authentication types
      #
      # * account/key
      # * user (with +is_group_admin+)
      def update_user(user)
        savon_request(:update_user, returns_error_string: true) do |soap|
          soap.message({})
          user.to_soap(soap[:message])
        end
      end

      # Renames a user
      #
      # The user cannot be renamed from one group to another - the group part of
      # the user id should remain the same.
      #
      # Raises a Symgate::Error on failure (e.g. the +new_user_id+ is already taken
      # or the user with +old_user_id+ does not exist)
      #
      # ==== Attributes
      #
      # * +old_user_id+ - The ID of the user to rename, in 'group_id/username' format (String)
      # * +new_user_id+ - The new ID of the renamed user (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      # * user (with +is_group_admin+)
      def rename_user(old_user_id, new_user_id)
        savon_request(:rename_user, returns_error_string: true) do |soap|
          soap.message(old_user_id: old_user_id, new_user_id: new_user_id)
        end
      end

      # Moves a user between groups
      #
      # Moves a user from one group to another. The group part of the user ID should
      # be changed.
      #
      # Raises a Symgate::Error on failure (e.g. the +new_user_id+ is already taken
      # or the user with +old_user_id+ does not exist)
      #
      # ==== Attributes
      #
      # * +old_user_id+ - The ID of the user to move, in 'group_id/username' format (String)
      # * +new_user_id+ - The new ID of the renamed user (String)
      #
      # ==== Example
      #
      #     auth_client.move_user('group_1/username', 'group_2/username')
      #
      # ==== Supported authentication types
      #
      # * account/key
      def move_user(old_user_id, new_user_id)
        savon_request(:move_user, returns_error_string: true) do |soap|
          soap.message(old_user_id: old_user_id, new_user_id: new_user_id)
        end
      end

      # Sets the password for a user
      #
      # Note that when authenticating as a user without the +is_group_admin+ permission
      # you can only change the password for yourself.
      #
      # Raises a Symgate::Error on failure (e.g. the user identified by +user_id+
      # does not exist, or you do not have sufficient permissions to update the password.)
      #
      # ==== Attributes
      #
      # * +user_id+ - The ID of the user for whom the password is to be changed
      #
      # ==== Supported authentication types
      #
      # * account/key
      # * user
      def set_user_password(user_id, password)
        savon_request(:set_user_password, returns_error_string: true) do |soap|
          soap.message(userid: user_id, password: password)
        end
      end

      # Destroys a user
      #
      # *IMPORTANT*: This will irreversibly destroy all wordlists and metadata
      # belonging to the user
      #
      # ==== Attributes
      #
      # * +user_id+ - The ID of the user for whom the password is to be changed
      #
      # ==== Supported authentication types
      #
      # * account/key
      # * user (with +is_group_admin+)
      def destroy_user(user_id)
        savon_request(:destroy_user, returns_error_string: true) do |soap|
          soap.message(userid: user_id)
        end
      end

      # Authenticates a user and returns a token
      #
      # This optionally provides a token which allows you to 'impersonate' a user
      # (i.e. use the API as if you were logged on as that user)
      #
      # Raises a Symgate::Error on error (e.g. authentication fails)
      #
      # ==== Attributes
      #
      # * +user_to_impersonate+ (optional) - The ID (String) of the user to impersonate
      #
      # ==== Returns
      #
      # A token, used for further calls to the client (String)
      #
      # * account/key (requires +user_to_impersonate+)
      # * user (cannot use +user_to_impersonate+)
      def authenticate(user_to_impersonate = nil)
        r = savon_request(:authenticate) do |soap|
          soap.message(userid: user_to_impersonate) if user_to_impersonate
        end.body[:authenticate_response]

        r ? r[:authtoken] : nil
      end

      # Adds a language to the specified group
      #
      # This enables users within the group to use the Symboliser in that language.
      #
      # ==== Attributes
      #
      # * +group+ - The ID of the group to add the language to (String)
      # * +language+ - The cml language to enable (String)
      #
      # ==== Returns
      #
      # Returns 'OK' if successful or 'Exists' if the language is already assigned
      # to the account (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      def add_group_language(group, language)
        savon_request(:add_group_language) do |soap|
          soap.message(groupid: group, language: language)
        end.body[:add_group_language_response]
      end

      # Removes a language from the specified group
      #
      # This prevents users within the group to use the Symboliser in that language.
      #
      # ==== Attributes
      #
      # * +group+ - The ID of the group to remove the language from(String)
      # * +language+ - The cml language to disable (String)
      #
      # ==== Returns
      #
      # Returns 'OK' if successful or 'NotExist' if the language is not assigned
      # to the account (String)
      #
      # ==== Supported authentication types
      #
      # * account/key
      def remove_group_language(group, language)
        savon_request(:remove_group_language) do |soap|
          soap.message(groupid: group, language: language)
        end.body[:remove_group_language_response]
      end

      # Lists the allowed languages for the specified group
      #
      # ==== Attributes
      #
      # * +group_id+ - The ID of the group (String)
      #
      # ==== Returns
      #
      # Returns an array of cml languages as strings
      #
      # ==== Supported authentication types
      #
      # * account/key
      def enumerate_group_languages(group_id)
        resp = savon_request(:enumerate_group_languages) { |soap| soap.message(groupid: group_id) }

        Symgate::Client.savon_array(
          resp.body[:enumerate_group_languages_response],
          :language
        )
      end

      # Queries whether a language is assigned to a group
      #
      # ==== Attributes
      #
      # * +group+ - The ID of the group  (String)
      # * +language+ - The cml language to query (String)
      #
      # ==== Returns
      #
      # Returns true if the user has the language assigned, otherwise false (Boolean)
      #
      # ==== Supported authentication types
      #
      # * account/key
      def query_group_language(group_id, language)
        savon_request(:query_group_language) do |soap|
          soap.message(groupid: group_id, language: language)
        end.body[:query_group_language_response]
      end

      # Lists the allowed languages for the currently authenticated user
      #
      # ==== Returns
      #
      # Returns an array of cml languages as strings
      #
      # ==== Supported authentication types
      #
      # * user
      def enumerate_languages
        resp = savon_request(:enumerate_languages)

        Symgate::Client.savon_array(
          resp.body[:enumerate_languages_response],
          :language
        )
      end

      # Queries whether a language is assigned to the currently authenticated user
      #
      # ==== Attributes
      #
      # * +language+ - The cml language to query (String)
      #
      # ==== Returns
      #
      # Returns true if the user has the language assigned, otherwise false (Boolean)
      #
      # ==== Supported authentication types
      #
      # * user
      def query_language(language)
        savon_request(:query_language) { |soap| soap.message(language: language) }
          .body[:query_language_response]
      end
    end
  end
end
