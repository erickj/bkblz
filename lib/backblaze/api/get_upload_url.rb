module Backblaze
  module Api

    class GetUploadUrlResponse < Response
      response_model Model::UploadAuth
    end

    class GetUploadUrlRequest < Request

      response_class Api::GetUploadUrlResponse
      url_suffix "/b2api/v1/b2_get_upload_url"

      def initialize(bucket_id)
        @body = {:bucket_id => bucket_id}
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
