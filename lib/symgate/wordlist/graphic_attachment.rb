require 'symgate/type'
require 'base64'

module Symgate
  module Wordlist
    # contains an embedded wordlist entry graphic
    class GraphicAttachment < Symgate::Type
      def self.from_soap(hash)
        data = hash_value_with_optional_namespace(:wl, :data, hash)

        Symgate::Wordlist::GraphicAttachment.new(
          type: hash_value_with_optional_namespace(:wl, :type, hash),
          uuid: hash_value_with_optional_namespace(:wl, :uuid, hash),
          data: data ? Base64.decode64(data) : nil
        )
      end

      def to_soap
        {
          %s(wl:type) => @type,
          %s(wl:uuid) => @uuid,
          %s(wl:data) => @data ? Base64.encode64(@data) : nil
        }
      end

      def to_s
        "{#{@type} Attachment: #{@uuid} (#{@data.length} bytes)}"
      end

      protected

      def attributes
        %i(type uuid data)
      end
    end
  end
end
