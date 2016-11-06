module Bkblz
  module V1

    class ListFileNamesResponse < PaginatedResponse
      response_accessor :files, Model::FileInfo
      pagination_accessors :next_file_name

      def build_next_request(limit)
        bucket = original_request.bucket
        limit ||= files.size
        ListFileNamesRequest.new bucket, limit, next_file_name
      end
    end

    class ListFileNamesRequest < Request

      response_class ListFileNamesResponse
      url_suffix "/b2api/v1/b2_list_file_names"

      attr_reader :bucket

      def initialize(bucket, max_file_count=1000, start_file_name=nil)
        @bucket = bucket
        @body = {}
        @body[:bucket_id] = bucket.bucket_id
        @body[:max_file_count] = max_file_count
        @body[:start_file_name] = start_file_name if start_file_name
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
