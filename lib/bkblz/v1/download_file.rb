module Bkblz
  module V1

    class DownloadFileResponse < Response
      response_model Model::FileDownload

      def parse(http_response)
        file_download_fields = {
         :body => http_response.body,
         :content_length => http_response["content-length"],
         :content_type => http_response["content-type"],
         :file_id => http_response["x-bz-file-id"],
         :file_name => http_response["x-bz-file-name"],
         :sha1 => http_response["x-bz-content-sha1"],
         :x_bz_info => {}
        }

        http_response.each_header do |k, v|
          if k.to_s.downcase.match /^x-bz-info/
            file_download_fields[:x_bz_info][k.to_sym] = v
          end
        end

        file_download_fields
      end
    end

    class DownloadFileByIdRequest < Request

      response_class DownloadFileResponse
      url_suffix "/b2api/v1/b2_download_file_by_id"

      def initialize(file_info, byte_range=nil)
        @body = {:file_id => file_info.file_id}
        @byte_range = byte_range
      end

      def build_request(session)
        headers = {}
        headers[:Range] = "bytes=%d-%d" % @byte_range.minmax if @byte_range
        session.create_post url(session), @body, headers
      end
    end

    class DownloadFileByNameRequest < Request

      response_class DownloadFileResponse

      def initialize(bucket, file_name, byte_range=nil)
        @bucket = bucket
        @file_name = file_name
        @byte_range = byte_range
      end

      def build_request(session)
        headers = {}
        headers[:Range] = "bytes=%d-%d" % @byte_range.minmax if @byte_range
        session.create_get url_for_file(session), headers
      end

      private
      def url_for_file(session)
        session.create_download_url(
          ["file", @bucket.bucket_name, @file_name].join "/")
      end
    end
  end
end
