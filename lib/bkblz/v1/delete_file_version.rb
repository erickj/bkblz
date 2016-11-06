module Bkblz
  module V1

    class DeleteFileVersionResponse < Response
      response_model Model::PartialFileInfo
    end

    class DeleteFileVersionRequest < Request

      response_class DeleteFileVersionResponse
      url_suffix "/b2api/v1/b2_delete_file_version"

      def initialize(short_file_info)
        @body = {:file_name => short_file_info.file_name,
                 :file_id => short_file_info.file_id}
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
