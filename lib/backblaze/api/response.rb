require 'json'

module Backblaze
  module Api
    class Response

      MissingResponseError = Class.new Backblaze::BaseError

      attr_reader :parsed_body, :http_response

      class << self

        def response_model(klass=nil)
          @response_model = klass unless klass.nil?
          @response_model
        end

        def response_accessors(*response_fields)
          response_fields.each do |response_field|
            response_accessor response_field
          end
        end

        def response_accessor(response_field, model_klass=nil, &block)
          api_map_key_converter = lambda do |map|
            raise "not a Hash" unless map.is_a? Hash
            Backblaze::MapKeyFormatter.underscore_keys map
          end
          api_value_transformer = lambda do |value|
            return value unless model_klass || block_given?
            return yield value if block_given?

            if value.is_a? Array
              value.map do |v|
                model_klass.new api_map_key_converter.call(v)
              end
            else
              model_klass.new api_map_key_converter.call(value)
            end
          end

          define_method response_field do |*args|
            raise MissingResponseError unless @response
            return @cache[response_field] if @cache.key? response_field

            value = @response[response_field]
            @cache[response_field] = api_value_transformer.call value
          end
        end
      end

      def initialize(http_response)
        @http_response = http_response
        @response = parse http_response
        @cache = {}
        Backblaze.log.debug { "parsed response => #{@response}" }
      end

      def to_model
        raise 'no response model defined' unless self.class.response_model
        self.class.response_model.new @response.dup
      end

      private
      def parse(http_response)
        Backblaze.log.info "content-type => #{http_response['content-type']}"

        parsed_json = JSON.parse http_response.body, {
                                   :allow_nan => true,
                                   :symbolize_names => true,
                                   :max_nesting => 4
                                 }
        Backblaze::MapKeyFormatter.underscore_keys parsed_json
      end
    end
  end
end
