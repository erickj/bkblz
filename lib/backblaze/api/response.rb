require 'json'

module Backblaze
  module Api
    class Response

      MissingResponseError = Class.new Backblaze::BaseError

      attr_reader :parsed_body, :http_response

      class << self
        def response_accessors(*response_fields)
          response_fields.each do |response_field|
            define_method response_field do
              raise MissingResponseError unless @parsed_body
              @parsed_body[response_field]
            end
          end
        end
      end

      def initialize(http_response)
        @http_response = http_response
        @parsed_body = parse http_response
      end

      private
      def parse(http_response)
        Backblaze.log.info "content-type => #{http_response['content-type']}"

        JSON.parse http_response.body, {
                     :allow_nan => true,
                     :symbolize_names => true,
                     :max_nesting => 4
                   }
      end
    end
  end
end
