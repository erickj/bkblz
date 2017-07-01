module Bkblz
  module V1

    class GetFileInfoResponse < Response
      response_model Model::FileInfo
    end

    class GetFileInfoRequest < Request

      response_class GetFileInfoResponse
      url_suffix "/b2api/v1/b2_get_file_info"

      def initialize(file_id)
        @file_id = file_id
      end

      def build_request(session)
        session.create_post url(session), :file_id => @file_id
      end
    end
  end
end
