module Backblaze
  module V1
    class AuthorizeAccountResponse < Response
      response_accessors :account_id,
                         :api_url,
                         :authorization_token,
                         :download_url,
                         :minimum_part_size
    end

    class AuthorizeAccountRequest < Request

      API_URL = "https://api.backblazeb2.com/b2api/v1/b2_authorize_account"

      response_class AuthorizeAccountResponse

      def build_request(session)
        req = Net::HTTP::Get.new URI(API_URL)
        req.basic_auth(session.config.account_id, session.config.application_key)
        req
      end
    end
  end
end
