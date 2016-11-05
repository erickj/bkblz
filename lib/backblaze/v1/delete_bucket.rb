module Backblaze
  module V1

    class DeleteBucketResponse < Response
      response_model Model::Bucket
    end

    class DeleteBucketRequest < Request

      response_class DeleteBucketResponse
      url_suffix "/b2api/v1/b2_delete_bucket"

      def initialize(bucket_model)
        @body = {:bucket_id => bucket_model.bucket_id,
                 :account_id => bucket_model.account_id}
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
