require 'net/http'

module Bkblz
  module V1

    TooManyRedirectError = Class.new Bkblz::BaseError

    class RequestError < Bkblz::BaseError

      def self.create(error_response)
        case error_response.to_model.status
        when 401
          UnauthorizedRequestError.new error_response
        else
          RequestError.new error_response
        end
      end

      def initialize(error_response)
        super error_response.message
      end
    end

    UnauthorizedRequestError = Class.new RequestError

    class Request

      class << self
        def response_class(klass=nil)
          @response_class = klass unless klass.nil?
          @response_class
        end

        def url_suffix(suffix=nil)
          @url_suffix = suffix unless suffix.nil?
          @url_suffix
        end
      end

      def send(session)
        request = build_request session
        Bkblz.log.debug { "sending request => #{request} to URI => #{request.uri}" }
        http = Net::HTTP.new(request.uri.host, request.uri.port)
        http.use_ssl = true
        http.set_debug_output(STDERR) if session.config.debug_http

        build_response fetch(http, request)
      end

      protected

      def build_request(session)
        raise 'not implemented'
      end

      def build_response(response)
        unless response.kind_of? Net::HTTPSuccess
          error_response = ErrorResponse.new response, self
          raise RequestError.create error_response
        end
        Bkblz.log.debug { "#build_response => #{response}" }

        response_class = self.class.response_class || Response
        response_class.new response, self
      end

      def url(session)
        raise "no URL suffix for #{self.class}" unless self.class.url_suffix
        session.create_url(self.class.url_suffix)
      end

      private

      def fetch(http, request, limit=10)
        # You should choose a better exception.
        raise TooManyRedirectError, 'too many HTTP redirects' if limit == 0

        response = http.start { |http| http.request(request) }

        case response
        when Net::HTTPSuccess then
          response
        when Net::HTTPRedirection then
          location = response['location']
          Bkblz.log.warn "redirected to #{location}"
          fetch http, location, limit - 1
        else
          response
        end
      end
    end
  end
end
