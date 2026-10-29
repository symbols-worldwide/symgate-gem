require 'symgate/cml/symbol'
require 'symgate/wordlist/custom_nlp'
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
          last_change: hash_value_with_optional_namespace(:wl, :lastchange, hash),
          custom_nlp: custom_nlp_from_soap(hash)
        )
      end

      def self.custom_nlp_from_soap(hash)
        value = hash[:customnlp] || hash[:'wl:customnlp']
        return [] if value.nil?

        [value].flatten.map { |item| Symgate::Wordlist::CustomNlp.from_soap(item) }
      end
      private_class_method :custom_nlp_from_soap

      def to_soap
        nlp = @custom_nlp.tryit { map(&:to_soap) }

        {
          %s(wl:word) => word,
          %s(wl:priority) => priority,
          %s(wl:uuid) => uuid,
          %s(wl:conceptcode) => value_or_nil(concept_code),
          %s(cml:symbol) => @symbols.tryit { map(&:to_soap) },
          %s(wl:customgraphic) => @custom_graphics.tryit { map(&:to_soap) },
          %s(wl:lastchange) => last_change&.to_s,
          %s(wl:customnlp) => nlp.nil? || nlp.empty? ? nil : nlp
        }.delete_if { |_, v| v.nil? }
      end

      def to_s
        "{Entry: #{@word}[#{@priority}]/#{@uuid} (#{@symbols.count}+#{@custom_graphics.count})}"
      end

      protected

      def attributes
        %i[word uuid priority concept_code symbols custom_graphics last_change custom_nlp]
      end
    end
  end
end
