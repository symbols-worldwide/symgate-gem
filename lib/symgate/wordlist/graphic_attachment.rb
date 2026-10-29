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
          data: data ? Base64.decode64(data) : nil,
          uri: hash_value_with_optional_namespace(:wl, :uri, hash)
        )
      end

      def to_soap
        soap = {
          %s(wl:type) => @type,
          %s(wl:uuid) => @uuid
        }

        if @uri.nil? || @uri.empty?
          soap[:'wl:data'] = @data ? Base64.encode64(@data) : nil
        else
          soap[:'wl:uri'] = @uri
        end

        soap
      end

      def to_s
        detail = if @data
                   "#{@data.length} bytes"
                 elsif @uri && !@uri.empty?
                   @uri
                 else
                   'no data'
                 end

        "{#{@type} Attachment: #{@uuid} (#{detail})}"
      end

      protected

      def attributes
        %i[type uuid data uri]
      end
    end
  end
end
