module Bkblz
  module V1

    class GetUploadPartUrlResponse < Response
      response_model Model::UploadPartAuth
    end

    class GetUploadPartUrlRequest < Request

      response_class GetUploadPartUrlResponse
      url_suffix "/b2api/v1/b2_get_upload_part_url"

      def initialize(file_id)
        @body = {:file_id => file_id}
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
