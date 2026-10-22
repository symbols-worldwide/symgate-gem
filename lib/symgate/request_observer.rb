require 'savon'

module Symgate
  # Captures the SOAP request XML for the current thread.
  #
  # Savon does not attach the request to SOAPFault. The mock observer must stay
  # last in Savon's observer list, because only the last observer's return
  # value is used.
  class RequestObserver
    THREAD_KEY = :symgate_last_request_xml

    def self.install
      Savon.observers.unshift(new) unless installed?
    end

    def self.installed?
      Savon.observers.any? { |observer| observer.is_a?(self) }
    end

    def self.consume_request_xml
      xml = Thread.current[THREAD_KEY]
      Thread.current[THREAD_KEY] = nil
      xml
    end

    def notify(_operation_name, builder, _globals, _locals)
      Thread.current[THREAD_KEY] = builder.to_s
      nil
    end
  end
end
