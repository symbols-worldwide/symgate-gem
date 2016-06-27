module Symgate
  # Defines a symgate-specific error so this can be caught by the caller
  class Error < StandardError
    def initialize(message)
      super(message)
    end
  end
end
