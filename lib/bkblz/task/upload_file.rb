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
        file_body = if params[:file_path]
                      f = ::File.new(params[:file_path], "r")
                      f.read
                    elsif params[:file_body]
                      params[:file_body]
                    else
                      raise 'missing either :file_body or :file_path param'
                    end

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

        if params[:gzip]
          # https://ruby-doc.org/stdlib-2.4.2/libdoc/zlib/rdoc/Zlib.html#method-c-gzip
          file_body = Zlib.gzip file_body, level: Zlib::DEFAULT_COMPRESSION
          file_name << ".gz" unless file_name =~ /\.gz$/
        end

        bucket = find_bucket_by_name session, params[:bucket_name]
        upload_auth = session.send(
          Bkblz::V1::GetUploadUrlRequest.new bucket.bucket_id).to_model

        upload_file_info = session.send(
          Bkblz::V1::UploadFileRequest.new(
            upload_auth, file_body, file_name, nil, file_mtime)).to_model
      end
    end
  end
end
