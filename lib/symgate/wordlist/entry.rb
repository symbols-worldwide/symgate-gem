require 'symgate/cml/symbol'
require 'symgate/type'
require 'symgate/client'

module Symgate
  module Wordlist
    # a wordlist entry
    class Entry < Symgate::Type
      def self.from_soap(hash)
        Symgate::Wordlist::Entry.new(
          word: hash_value_with_optional_namespace(:wl, :word, hash),
          uuid: hash_value_with_optional_namespace(:wl, :uuid, hash),
          priority: hash_value_with_optional_namespace(:wl, :priority, hash),
          concept_code: hash_value_with_optional_namespace(:wl, :conceptcode, hash),
          symbols: Symgate::Client.savon_array(hash, :symbol,
                                               Symgate::Cml::Symbol),
          custom_graphics: Symgate::Client.savon_array(hash, :customgraphic,
                                                       Symgate::Wordlist::GraphicAttachment),
          last_change: hash_value_with_optional_namespace(:wl, :lastchange, hash)
        )
      end

      def to_soap
        {
          'wl:word': word,
          'wl:uuid': uuid,
          'wl:priority': priority,
          'wl:conceptcode': concept_code.to_s == '' ? nil : concept_code,
          'cml:symbol': @symbols.map(&to_soap),
          'wl:customgraphic': @custom_graphics.map(&to_soap),
          'wl:lastchange': last_change
        }.compact
      end

      def to_s
        "{Entry: #{@word}[#{@priority}]/#{@uuid} (#{@symbols.count}+#{@custom_graphics.count})}"
      end

      protected

      def attributes
        %i(word uuid priority concept_code symbols custom_graphics last_change)
      end
    end
  end
end
