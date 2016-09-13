require 'symgate/cml/symbol'
require 'symgate/wordlist/graphic_attachment'
require 'symgate/type'
require 'symgate/client'
require 'tryit'

module Symgate
  module Wordlist
    # a wordlist entry
    class Entry < Symgate::Type
      def self.from_soap(hash)
        Symgate::Wordlist::Entry.new(
          word: hash_value_with_optional_namespace(:wl, :word, hash),
          uuid: hash_value_with_optional_namespace(:wl, :uuid, hash),
          priority: hash_value_with_optional_namespace(:wl, :priority, hash).to_i,
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
          %s(wl:word) => word,
          %s(wl:uuid) => uuid,
          %s(wl:priority) => priority,
          %s(wl:conceptcode) => value_or_nil(concept_code),
          %s(cml:symbol) => @symbols.tryit { map(&:to_soap) },
          %s(wl:customgraphic) => @custom_graphics.tryit { map(&:to_soap) },
          %s(wl:lastchange) => last_change.to_s
        }.delete_if { |_, v| v.nil? }
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
