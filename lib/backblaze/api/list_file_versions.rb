module Backblaze
  module Api

    class ListFileVersionsResponse < PaginatedResponse
      response_accessor :files, Model::FileInfo
      pagination_accessors :next_file_name, :next_file_id

      def build_next_request(limit)
        ListFileVersionsRequest.new self.bucket_id, limit, self
      end
    end

    class ListFileVersionsRequest < Request

      response_class ListFileVersionsResponse
      url_suffix "/b2api/v1/b2_list_file_versions"

      def initialize(bucket, max_file_count=1000, paginate_from=nil)
        @body = {}
        @body[:bucket_id] = bucket.bucket_id
        @max_file_count = max_file_count

        if paginate_from
          raise 'invalid paginator' unless paginate_from.is_a? ListBucketsResponse

          next_file_name = paginate_from.next_file_name
          next_file_id = paginate_from.next_file_id

          @body[:start_file_name] = next_file_name if next_file_name
          @body[:start_file_id] = next_file_id if next_file_id
        end
      end

      def build_request(session)
        session.create_post url(session), @body
      end
    end
  end
end
