module Backblaze
  module Api

    class DeleteBucketResponse < Response
      response_model Model::Bucket
    end

    class DeleteBucketRequest < Request

      response_class Api::CreateBucketResponse
      url_suffix "/b2api/v1/b2_delete_bucket"

      def initialize(bucket_model)
        @body = bucket_model.to_map
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
