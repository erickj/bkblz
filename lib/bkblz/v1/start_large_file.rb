require "digest/sha1"

module Bkblz
  module V1

    class StartLargeFileResponse < Response
      response_model Model::FileInfo
    end

    class StartLargeFileRequest < Request

      response_class StartLargeFileResponse
      url_suffix "/b2api/v1/b2_start_large_file"

      def initialize(bucket_id, file_name, last_modified_millis=nil,
          file_sha=nil, content_type='b2/x-auto', **file_info)
        # Both of the following are recommended here:
        # https://www.backblaze.com/b2/docs/b2_start_large_file.html
        if last_modified_millis
          # must be a string
          file_info[:src_last_modified_millis] = last_modified_millis.to_s
        end
        if file_sha
          file_info[:large_file_sha1] = file_sha
        end

        @body = {
          :bucket_id => bucket_id,
          :file_name => file_name,
          :content_type => content_type,
          :file_info => file_info
        }
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
