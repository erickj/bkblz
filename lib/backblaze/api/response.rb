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
            raise MissingResponseError unless @parsed_response
            return @cache[response_field] if @cache.key? response_field

            value = @parsed_response[response_field]
            @cache[response_field] = api_value_transformer.call value
          end
        end
      end

      def initialize(http_response, original_request)
        @http_response = http_response
        @original_request = original_request

        @parsed_response = parse http_response
        @cache = {}
        Backblaze.log.debug { "parsed response => #{@parsed_response}" }
      end

      attr_reader :original_request
      protected :original_request

      def [](key)
        @parsed_response[key]
      end

      def to_model
        raise 'no response model defined' unless self.class.response_model
        self.class.response_model.new @parsed_response.dup
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

    class PaginatedResponse < Response

      NoMorePagesError = Class.new Backblaze::BaseError

      class << self

        attr_reader :pagination_fields
        def pagination_accessors(*pagination_fields)
          response_accessors *pagination_fields

          @pagination_fields ||= []
          @pagination_fields.concat pagination_fields
        end
      end

      def has_more?
        self.class.pagination_fields.any? { |f| !self[f].nil? }
      end

      def next_request(limit=nil)
        raise NoMorePagesError unless has_more?
        build_next_request(limit)
      end

      private
      def build_next_request(limit)
        raise "not implemented"
      end
    end
  end
end
