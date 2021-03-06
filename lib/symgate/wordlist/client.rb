require 'base64'
require 'symgate/client'
require 'symgate/error'
require 'symgate/wordlist/info'
require 'symgate/wordlist/entry'

module Symgate
  module Wordlist
    # client for the Symgate wordlist system
    class Client < Symgate::Client
      # returns a list of wordlists available to the current user.
      # optionally, supply one or more wordlist contexts as a string or string array parameter
      # to only retrieve wordlist information about that context. e.g.:
      # enumerate_wordlists('User')
      # enumerate_wordlists(%w[Topic SymbolSet])
      def enumerate_wordlists(context = [])
        response = savon_request(:enumerate_wordlists) do |soap|
          soap.message(context: [context].flatten)
        end

        Symgate::Client.savon_array(
          response.body[:enumerate_wordlists_response],
          :wordlistinfo,
          Symgate::Wordlist::Info
        )
      end

      # creates a wordlist with the specified name, context and scope (see auth:scope).
      # optionally, supply a list of entries to form the wordlist's initial content
      def create_wordlist(name, context, entries = [], readonly: false)
        tries ||= 3 # TODO: Find out if we still need to do this!

        Symgate::Wordlist::Info.from_soap(
          savon_request(:create_wordlist) do |soap|
            soap.message(soap_params_for_create_wordlist(name, context, readonly, entries))
          end.body[:create_wordlist_response][:wordlistinfo]
        )
      rescue Symgate::Error => e
        # Handle SOS-105 (sometimes the wordlist is created but the symboliser claims it can't
        # find it and sends a SOAP error back) by extracting the wordlist UUID from the error
        # message. Yes, this is not nice.
        match = /^No wordlist found for ID: ({[0-9a-f-]{36}})$/.match(e.detail)

        return get_wordlist_info(match[1]) if match
        (tries -= 1).zero? ? raise(e) : retry
      end

      # destroys a wordlist with the specified uuid. throws an error on failure
      def destroy_wordlist(uuid)
        tries ||= 3 # TODO: Find out if we still need to do this!

        savon_request(:destroy_wordlist, returns_error_string: true) do |soap|
          soap.message(wordlistid: uuid)
        end
      rescue Symgate::Error => e
        (tries -= 1).zero? ? raise(e) : retry
      end

      # returns the information for the wordlist identified by the specified uuid
      def get_wordlist_info(uuid)
        response = savon_request(:get_wordlist_info) do |soap|
          soap.message(wordlistid: uuid)
        end

        Symgate::Wordlist::Info.from_soap(
          response.body[:get_wordlist_info_response][:wordlistinfo]
        )
      end

      # Copies a wordlist with the specified UUID with optional parameters to specify the destination wordlist UUID, the
      # context, name and readonlyness of the destination wordlist, source and destination group and/or user
      def copy_wordlist(src_uuid, dest_uuid: nil, context: nil, name: nil, readonly: nil,
                        src_group: nil, src_user: nil, dest_group: nil, dest_user: nil)
        response = savon_request(:copy_wordlist) do |soap|
          params = { srcwordlistuuid: src_uuid }
          params[:dstwordlistuuid] = dest_uuid unless dest_uuid.nil?
          params[:context] = context unless context.nil?
          params[:name] = name unless name.nil?
          params[:readonly] = readonly unless readonly.nil?
          params[:srcgroup] = src_group unless src_group.nil?
          params[:srcusername] = src_user unless src_user.nil?
          params[:dstgroup] = dest_group unless dest_group.nil?
          params[:dstusername] = dest_user unless dest_user.nil?
          soap.message(params)
        end

        Symgate::Wordlist::Info.from_soap(
          response.body[:copy_wordlist_response][:wordlistinfo]
        )
      end

      # returns all wordlist entries for the wordlist specified by uuid.
      # accepts the following optional parameters:
      #   attachments (boolean) - fetch custom graphics for the entries (default: false)
      #   match (string) - only return wordlist entries matching this word
      #   entry (string, uuid) - return the entry specified by the uuid
      def get_wordlist_entries(uuid, opts = {})
        check_for_unknown_opts(%i[match entry attachments], opts)
        check_for_multiple_opts(%i[match entry], opts)

        response = savon_request(:get_wordlist_entries) do |soap|
          soap.message(wordlistid: uuid, getattachments: !!opts[:attachments])
          soap[:message][:match] = { matchstring: opts[:match] } if opts.include? :match
          soap[:message][:match] = { entryid: opts[:entry] } if opts.include? :entry
        end

        Symgate::Client.savon_array(response.body[:get_wordlist_entries_response],
                                    :wordlistentry,
                                    Symgate::Wordlist::Entry)
      end

      # inserts an entry into a wordlist, specified by the wordlist uuid
      def insert_wordlist_entry(uuid, entry)
        unless entry.is_a? Symgate::Wordlist::Entry
          raise Symgate::Error, 'Please supply a Symgate::Wordlist::Entry to insert'
        end

        savon_request(:insert_wordlist_entry, returns_error_string: true) do |soap|
          soap.message(wordlistid: uuid, %s(wl:wordlistentry) => entry.to_soap)
        end
      end

      # overwrites a wordlist with the wordlist contents specified by 'entries'
      def overwrite_wordlist(uuid, entries)
        check_array_for_type(entries, Symgate::Wordlist::Entry)

        savon_request(:overwrite_wordlist, returns_error_string: true) do |soap|
          soap.message(wordlistid: uuid, %s(wl:wordlistentry) => entries.map(&:to_soap))
        end
      end

      # removes the wordlist entry specified by entry_uuid, from the wordlist specified by uuid
      def remove_wordlist_entry(uuid, entry_uuid)
        savon_request(:remove_wordlist_entry, returns_error_string: true) do |soap|
          soap.message(wordlistid: uuid, entryid: entry_uuid)
        end
      end

      # renames the wordlist specified by its uuid, to the name requested
      def rename_wordlist(uuid, name)
        savon_request(:rename_wordlist, returns_error_string: true) do |soap|
          soap.message(wordlistid: uuid, name: name)
        end
      end

      # gets the cfwl-format data for the specified wordlist
      def get_wordlist_as_cfwl_data(uuid)
        Base64.decode64(
          savon_request(:get_wordlist_as_cfwl_data) do |soap|
            soap.message(wordlistid: uuid)
          end.body[:get_wordlist_as_cfwl_data_response][:cfwl]
        )
      end

      # creates a wordlist from the supplied cfwl data, in the requested context
      # if 'preserve_uuid' is true, the new wordlist will have the same uuid as the file
      def create_wordlist_from_cfwl_data(raw_cfwl_data, context, preserve_uuid, readonly: false)
        savon_request(:create_wordlist_from_cfwl_data) do |soap|
          soap.message(cfwl: Base64.encode64(raw_cfwl_data),
                       context: context,
                       preserve_uuid: preserve_uuid,
                       readonly: readonly)
        end.body[:create_wordlist_from_cfwl_data_response][:uuid]
      end

      private

      def scope_for_context(context)
        case context.to_s
        when 'Topic', 'SymbolSet'
          'Group'
        when 'Lexical'
          'Account'
        else
          'User'
        end
      end

      def soap_params_for_create_wordlist(name, context, readonly, entries)
        {
          name: name,
          context: context,
          scope: scope_for_context(context),
          readonly: readonly
        }.merge(
          entries ? { %s(wl:wordlistentry) => entries.map(&:to_soap) } : {}
        )
      end
    end
  end
end
