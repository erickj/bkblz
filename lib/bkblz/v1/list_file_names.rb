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

    # https://www.backblaze.com/b2/docs/b2_list_file_names.html
    class ListFileNamesRequest < Request

      response_class ListFileNamesResponse
      url_suffix "/b2api/v1/b2_list_file_names"

      attr_reader :bucket

      # TODO(erick): Switch start_file_name to a keyword arg
      def initialize(bucket, max_file_count=1000, start_file_name=nil,
          prefix: nil, delimiter: nil)
        @bucket = bucket
        @body = {}
        @body[:bucket_id] = bucket.bucket_id
        @body[:max_file_count] = max_file_count
        @body[:start_file_name] = start_file_name if start_file_name
        @body[:prefix] = prefix if prefix
        @body[:delimiter] = delimiter if delimiter
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
