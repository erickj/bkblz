require "digest/sha1"

module Bkblz
  module V1

    TooManyBzInfoHeadersError = Class.new Bkblz::BaseError

    class UploadFileResponse < Response
      response_model Model::FileInfo
    end

    class UploadFileRequest < Request

      response_class UploadFileResponse

      REQUIRED_HEADERS = {
                          :"Authorization" => nil,
                          :"X-Bz-File-Name" => nil,
                          :"Content-Type" => "b2/x-auto",
                          :"Content-Length" => nil,
                          :"X-Bz-Content-Sha1" => nil
      }

      def initialize(upload_auth, body, file_name, content_type=nil,
                     last_modified_millis=nil, **bz_info)
        unless last_modified_millis
          # Recommended https://www.backblaze.com/b2/docs/b2_upload_file.html
          bz_info["src_last_modified_millis"] = last_modified_millis
        end
        raise TooManyBzInfoHeadersError, bz_info_headers if bz_info.size > 10

        @upload_url = upload_auth.upload_url
        @body = body.is_a?(IO) ? body.read : body
        @headers = REQUIRED_HEADERS.dup
        bz_info.each do |k,v|
          @headers["X-Bz-Info-#{k.to-s}".to_sym] = v
        end

        @headers[:"Authorization"] = upload_auth.authorization_token
        @headers[:"X-Bz-File-Name"] = file_name
        @headers[:"Content-Length"] = @body.size
        @headers[:"X-Bz-Content-Sha1"] = Digest::SHA1.hexdigest @body
      end

      def build_request(session)
        session.create_post @upload_url, @body, @headers
      end
    end
  end
end
