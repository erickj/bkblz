require 'uri'

module Bkblz
  module V1

    SessionNotAuthorizedError = Class.new Bkblz::BaseError

    class Session

      class << self
        def authorize(config, &block)
          session = Session.new config
          session.auth_response =
            session.send Bkblz::V1::AuthorizeAccountRequest.new

          yield(session) if block_given?
          session
        end
      end

      attr_accessor :config, :auth_response

      def initialize(config)
        @config = config
      end

      def send(request)
        request.send self
      end

      def account_id
        check_authorized
        auth_response.account_id
      end

      def authorized?
        !!auth_response && !!auth_response.authorization_token
      end

      def create_url(url_suffix)
        check_authorized
        URI.join auth_response.api_url, url_suffix
      end

      def create_post(url, body=nil, addl_headers={})
        Bkblz.log.debug { "creating post for request => #{url}" }
        check_authorized

        uri = url.is_a?(URI) ? url : URI(url)
        request = Net::HTTP::Post.new uri

        if body.is_a? Hash
          body = Bkblz::MapKeyFormatter.camelcase_keys(body).to_json
        end
        request.body = body if body

        headers = {:"Authorization" => auth_response.authorization_token}
        headers.merge(addl_headers).each do |k,v|
          Bkblz.log.debug2 { "adding request header => #{k}:#{v}" }
          request.add_field k.to_s, v unless v.nil?
        end

        request
      end

      private
      def check_authorized
        raise SessionNotAuthorizedError unless authorized?
      end
    end
  end
end