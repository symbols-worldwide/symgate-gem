require 'symgate/type'

module Symgate
  module Cml
    # defines the cml symbol information for a concept
    class Symbol < Symgate::Type
      def self.from_soap(hash)
        Symgate::Cml::Symbol.new(
          symset: hash[:symset] || hash[:'cml:symset'],
          main: hash[:main] || hash[:'cml:main'],
          top_left: hash[:top_left] || hash[:'cml:top_left'],
          top_right: hash[:top_right] || hash[:'cml:top_right'],
          bottom_left: hash[:bottom_left] || hash[:'cml:bottom_left'],
          bottom_right: hash[:bottom_right] || hash[:'cml:bottom_right'],
          full_left: hash[:full_left] || hash[:'cml:full_left'],
          full_right: hash[:full_right] || hash[:'cml:full_right'],
          top: hash[:top] || hash[:'cml:top'],
          extra: hash[:extra] || hash[:'cml:extra']
        )
      end

      def to_soap
        {
          'cml:symset': symset,
          'cml:main': main,
          'cml:top_left': top_left,
          'cml:top_right': top_right,
          'cml:bottom_left': bottom_left,
          'cml:bottom_right': bottom_right,
          'cml:full_left': full_left,
          'cml:full_right': full_right,
          'cml:top': top,
          'cml:extra': extra
        }.compact
      end

      def to_s
        "Symbol: #{@main}"
      end

      protected

      def attributes
        %i(symset main top_left top_right bottom_left bottom_right full_left full_right top extra)
      end
    end
  end
end
