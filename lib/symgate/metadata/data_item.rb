module Symgate
  module Metadata
    # meta data item
    class DataItem
      attr_accessor :key, :value, :scope

      def initialize(opts = {})
        @key = opts[:key]
        @value = opts[:value]
        @scope = opts[:scope]
      end

      def self.from_soap(hash)
        Symgate::Metadata::DataItem.new(
          key: hash[:@key],
          scope: hash[:@scope],
          value: hash[:value]
        )
      end

      def operator=(other)
        @key = other.key
        @value = other.value
        @scope = other.scope
      end

      def ==(other)
        @key == other.key &&
          @value == other.value &&
          @scope == other.scope
      end

      def to_s
        "{DataItem (scope: #{scope}, key #{key}, value #{value})}"
      end
    end
  end
end
