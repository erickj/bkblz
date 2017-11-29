module Bkblz
  module Task
    class UploadFile < BaseTask

      task_param :bucket_name, :required => true
      task_param :file_body # Either file_body or file_path is required
      task_param :file_path
      task_param :file_name # Overrides local file_path if given

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
