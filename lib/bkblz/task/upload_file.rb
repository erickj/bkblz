require 'zlib'

module Bkblz
  module Task
    class UploadFile < BaseTask

      task_param :bucket_name, :required => true

      # Either file_body or file_path is required
      task_param :file_body

      task_param :file_path

      # Overrides local file_path if given
      task_param :file_name

      # Use gzip default compression before writing to b2 the file name will be
      # updated by appending ".gz"
      task_param :gzip

      def run_internal(session, params)
        file_name = if params[:file_name]
                      params[:file_name]
                    elsif params[:file_path]
                      ::File.basename(params[:file_path])
                    else
                      raise 'missing either :file_name or :file_path param'
                    end

        file_mtime = if params[:file_path]
                       ::File.mtime(params[:file_path])
                     else
                       Time.now
                     end.to_i * 1000

        bucket = find_bucket_by_name session, params[:bucket_name]
        size = file_size(params)

        file_data = {
          :file_name => file_name,
          :file_mtime => file_mtime,
          :file_size => size,
          :bucket => bucket,
        }

        if size > config.large_file_max_chunk_size
          upload_large_file session, params, **file_data
        else
          upload_file session, params, **file_data
        end
      end

      private
      def file_size(params)
        if params[:file_path]
          ::File.new(params[:file_path]).size
        elsif params[:file_body]
          params[:file_body].size
        end
      end

      def upload_large_file(session, params, bucket:, file_name:, file_mtime:, **file_data)
        start_large_file_info = session.send(Bkblz::V1::StartLargeFileRequest.new(
            bucket.bucket_id, file_name, file_mtime)).to_model
        file_id = start_large_file_info.file_id

        upload_part_auth = session.send(Bkblz::V1::GetUploadPartUrlRequest.new(file_id)).to_model

        actual_size = file_data[:file_size]
        chunk_size = config.large_file_max_chunk_size
        num_chunks = (actual_size / chunk_size.to_f).ceil

        file_io = if params[:file_path]
                    ::File.new(params[:file_path], "rb")
                  else
                    raise 'only file_path is supported for large file uploads'
                  end

        upload_part_infos = (0..num_chunks - 1).map do |chunk_i|
          session.send(Bkblz::V1::UploadPartRequest.new(
              upload_part_auth, file_io, chunk_i, chunk_size)).to_model
        end

        file_info = session.send(
          Bkblz::V1::FinishLargeFileRequest.new(file_id, upload_part_infos)).to_model
      end

      def upload_file(session, params, bucket:, file_name:, file_mtime:, **file_data)
        file_body = if params[:file_path]
                      f = ::File.new(params[:file_path], "r")
                      f.read
                    elsif params[:file_body]
                      params[:file_body]
                    else
                      raise 'missing either :file_body or :file_path param'
                    end

        if params[:gzip]
          # https://ruby-doc.org/stdlib-2.4.2/libdoc/zlib/rdoc/Zlib.html#method-c-gzip
          file_body = Zlib.gzip file_body, level: Zlib::DEFAULT_COMPRESSION
          file_name << ".gz" unless file_name =~ /\.gz$/
        end

        upload_auth = session.send(
          Bkblz::V1::GetUploadUrlRequest.new bucket.bucket_id).to_model

        upload_file_info = session.send(
          Bkblz::V1::UploadFileRequest.new(
            upload_auth, file_body, file_name, nil, file_mtime)).to_model
      end
    end
  end
end
