module Backblaze
  module V1

    class CreateBucketResponse < Response
      response_model Model::Bucket
    end

    class CreateBucketRequest < Request

      response_class CreateBucketResponse
      url_suffix "/b2api/v1/b2_create_bucket"

      def initialize(bucket_model)
        @body = bucket_model.to_map
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
