require 'symgate/type'

module Symgate
  module Wordlist
    # Custom NLP data for an inline wordlist entry.
    # The symboliser uses it to fake an SDB lookup. It cannot be stored in a wordlist.
    class CustomNlp < Symgate::Type
      def self.from_soap(hash)
        Symgate::Wordlist::CustomNlp.new(
          base: hash_value_with_optional_namespace(:wl, :base, hash),
          pos: hash_value_with_optional_namespace(:wl, :pos, hash),
          tags: hash_value_with_optional_namespace(:wl, :tags, hash),
          conceptcode: hash_value_with_optional_namespace(:wl, :conceptcode, hash)
        )
      end

      def to_soap
        {
          %s(wl:base) => base.to_s,
          %s(wl:pos) => pos.to_s,
          %s(wl:tags) => tags.to_s,
          %s(wl:conceptcode) => conceptcode.to_s
        }
      end

      def to_s
        "{CustomNlp: #{@base}/#{@pos} #{@conceptcode}}"
      end

      protected

      def attributes
        %i[base pos tags conceptcode]
      end
    end
  end
end
