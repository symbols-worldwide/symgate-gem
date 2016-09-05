require 'symgate/type'

module Symgate
  module Wordlist
    # contains information about a wordlist
    class Info < Symgate::Type
      def self.from_soap(hash)
        Symgate::Wordlist::Info.new(
          name: hash_value_with_optional_namespace(:wl, :name, hash),
          context: hash_value_with_optional_namespace(:wl, :context, hash),
          uuid: hash_value_with_optional_namespace(:wl, :uuid, hash),
          engine: hash_value_with_optional_namespace(:wl, :engine, hash),
          scope: hash_value_with_optional_namespace(:wl, :scope, hash),
          entry_count: hash_value_with_optional_namespace(:wl, :entrycount, hash),
          last_change: hash_value_with_optional_namespace(:wl, :lastchange, hash)
        )
      end

      def to_soap
        {
          name: @name,
          context: @context,
          uuid: @uuid,
          engine: @engine,
          scope: @scope,
          entrycount: @entrycount,
          lastchange: @lastchange
        }
      end

      def to_s
        "{#{@context} Wordlist: \"#{@name}\"/#{@uuid} (#{@engine}, #{@entry_count} entries)}"
      end

      protected

      def attributes
        %i(name context uuid entry_count last_change engine scope)
      end
    end
  end
end
