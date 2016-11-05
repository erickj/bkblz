require 'net/http'

module Backblaze
  module Api

    TooManyRedirectError = Class.new Backblaze::BaseError

    class Request

      class << self
        def response_class(klass=nil)
          @response_class = klass unless klass.nil?
          @response_class
        end
      end

      attr_reader :session

      def initialize(session)
        @session = session
        raise 'no response class configured' unless self.class.response_class
      end

      def send
        request = build_request
        http = Net::HTTP.new(request.uri.host, request.uri.port)
        http.use_ssl = true
        http.set_debug_output(STDERR) if @session.config.debug_http

        build_response fetch(http, request)
      end

      protected

      def build_request
        raise 'not implemented'
      end

      def build_response(response)
        self.class.response_class.new response
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
          warn "redirected to #{location}"
          fetch(http, location, limit - 1)
        else
          response
        end
      end
    end
  end
end
