module Backblaze
  module Api

    class ListBucketsResponse < Response
      response_accessor :buckets, Model::Bucket
    end

    class ListBucketsRequest < Request

      response_class Api::ListBucketsResponse
      url_suffix "/b2api/v1/b2_list_buckets"

      def build_request(session)
        session.create_post url(session), :account_id => session.account_id
      end
    end
  end
end
