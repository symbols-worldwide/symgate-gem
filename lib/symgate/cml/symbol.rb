require 'symgate/type'

module Symgate
  module Cml
    # defines the cml symbol information for a concept
    class Symbol < Symgate::Type
      def self.from_soap(hash)
        Symgate::Cml::Symbol.new(
          symset: hash_value_with_optional_namespace(:cml, :symset, hash),
          main: hash_value_with_optional_namespace(:cml, :main, hash),
          top_left: hash_value_with_optional_namespace(:cml, :top_left, hash),
          top_right: hash_value_with_optional_namespace(:cml, :top_right, hash),
          bottom_left: hash_value_with_optional_namespace(:cml, :bottom_left, hash),
          bottom_right: hash_value_with_optional_namespace(:cml, :bottom_right, hash),
          full_left: hash_value_with_optional_namespace(:cml, :full_left, hash),
          full_right: hash_value_with_optional_namespace(:cml, :full_right, hash),
          top: hash_value_with_optional_namespace(:cml, :top, hash),
          extra: hash_value_with_optional_namespace(:cml, :extra, hash)
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
        }.delete_if { |_, v| v.nil? }
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
