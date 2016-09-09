require 'symgate/error'

module Symgate
  # base class for API types, that provides magic initialisation from hash plus
  # assignment and comparison operators
  class Type
    def initialize(opts = {})
      attrs = attributes
      self.class.class_eval { attr_accessor(*attrs) }
      opts.each do |key, value|
        unless attributes.include? key
          raise Symgate::Error, "Unknown option #{key} for #{self.class.name}"
        end
        instance_variable_set "@#{key}", value
      end
    end

    def ==(other)
      attributes.all? do |a|
        other.instance_variable_get("@#{a}") == instance_variable_get("@#{a}")
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
  end
end
