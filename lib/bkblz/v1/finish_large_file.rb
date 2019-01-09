require "digest/sha1"

module Bkblz
  module V1

    class FinishLargeFileResponse < Response
      response_model Model::FileInfo
    end

    class FinishLargeFileRequest < Request

      response_class FinishLargeFileResponse
      url_suffix "/b2api/v1/b2_finish_large_file"

      def initialize(file_id, file_part_infos)
        sha1_sums = file_part_infos.sort { |a, b| a.part_number <=> b.part_number }.map do |info|
          info.content_sha1
        end
        @body = {
          :file_id => file_id,
          :part_sha1_array => sha1_sums,
        }
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
