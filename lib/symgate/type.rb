require 'symgate/error'

module Symgate
  # base class for API types, that provides magic initialisation from hash plus
  # assignment and comparison operators
  class Type
    def initialize(opts = {})
      attrs = attributes
      self.class.class_eval { attr_accessor(*attrs) }
      opts.each do |key, _value|
        unless attributes.include? key
          raise Symgate::Error, "Unknown option #{key} for #{self.class.name}"
        end
      end

      attributes.each do |attribute|
        instance_variable_set "@#{attribute}", opts[attribute]
      end
    end

    def ==(other)
      attributes.all? do |attribute|
        a = other.instance_variable_get("@#{attribute}")
        b = instance_variable_get("@#{attribute}")

        a == b || values_are_empty([a, b])
      end
    end

    def self.hash_value_with_optional_namespace(namespace, key, hash)
      hash[key] || hash["#{namespace}:#{key}".to_sym]
    end

    protected

    # override this to return an array of symbols for your class variables
    # :nocov:
    def attributes
      raise Symgate::Error, "No attributes defined for object type #{self.class.name}"
    end
    # :nocov:

    def value_or_nil(value)
      if value.respond_to?(:empty?) ? value.empty? : !value
        nil
      else
        value
      end
    end

    def values_are_empty(values)
      values.all? { |v| value_or_nil(v).nil? }
    end
  end
end
