require "digest/sha1"

module Bkblz
  module V1

    class UploadPartResponse < Response
      response_model Model::FilePartInfo
    end

    class UploadPartRequest < Request

      response_class UploadPartResponse

      REQUIRED_HEADERS = {
                          :"Authorization" => nil,
                          :"Content-Length" => nil,
                          :"Content-Type" => 'application/octet-stream',
                          :"X-Bz-Part-Number" => nil, # a value in [1..10000]
                          :"X-Bz-Content-Sha1" => nil
      }

      ##
      # @param {chunk_number} is a value in [0...9999]
      def initialize(upload_part_auth, io, chunk_number, chunk_size)
        @upload_url = upload_part_auth.upload_url
        @body_chunk = read_chunk(io, chunk_number, chunk_size)
        @headers = REQUIRED_HEADERS.dup

        part_number = chunk_number + 1
        @headers[:"Authorization"] = upload_part_auth.authorization_token
        @headers[:"Content-Length"] = @body_chunk.size
        @headers[:"X-Bz-Part-Number"] = part_number
        @headers[:"X-Bz-Content-Sha1"] = Digest::SHA1.hexdigest @body_chunk
      end

      def build_request(session)
        session.create_post @upload_url, @body_chunk, @headers
      end

      private
      def read_chunk(io, chunk_number, chunk_size)
        unless io.is_a?(IO)
          raise 'only IO type is supported for upload_part'
        end

        byte = chunk_number * chunk_size
        # https://ruby-doc.org/core-2.5/IO.html#method-i-seek
        io.seek byte, IO::SEEK_SET
        io.read(chunk_size)
      end
    end
  end
end
