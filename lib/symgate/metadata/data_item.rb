require 'symgate/type'

module Symgate
  module Metadata
    # meta data item
    class DataItem < Symgate::Type
      def self.from_soap(hash)
        Symgate::Metadata::DataItem.new(
          key: hash[:@key],
          scope: hash[:@scope],
          value: hash_value_with_optional_namespace(:auth, :value, hash)
        )
      end

      def to_soap
        {
          %s(@key) => key,
          %s(@scope) => scope,
          %s(auth:value) => value
        }
      end

      def to_s
        "{DataItem (scope: #{scope}, key #{key}, value #{value})}"
      end

      protected

      def attributes
        %i[key value scope]
      end
    end
  end
end
