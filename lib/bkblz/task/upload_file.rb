module Bkblz
  module Task
    class UploadFile < BaseTask

      task_param :bucket_name, :required => true
      task_param :file_path, :required => true
      task_param :file_name # Overrides local file_path if given

      # TODO(erick): Change file_path to a byte string, let the task be agnostic
      # to where the data comes from. (Probably v0.2).
      def run_internal(session, params)
        f = ::File.new(params[:file_path], "r")

        bucket = find_bucket_by_name session, params[:bucket_name]
        upload_auth = session.send(
          Bkblz::V1::GetUploadUrlRequest.new bucket.bucket_id).to_model

        file_name = params[:file_name] || ::File.basename(f.path)
        file_body = f.read
        mtime_millis = f.mtime.to_i * 1000

        upload_file_info = session.send(
          Bkblz::V1::UploadFileRequest.new upload_auth, file_body, file_name,
                                           nil, mtime_millis).to_model
      end
    end
  end
end
