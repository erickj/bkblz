require 'digest/sha1'

module Bkblz
  module Task
    class DownloadFile < BaseTask

      task_param :file_id, :required => true
      task_param :dir_path, :required => true

      def run_internal(session, params)
        partial_file_info =
          Bkblz::V1::Model::PartialFileInfo.new :file_id => params[:file_id]
        download_file_info = session.send(
          Bkblz::V1::DownloadFileByIdRequest.new partial_file_info).to_model

        unless download_file_info.sha1 == Digest::SHA1.hexdigest(download_file_info.body)
          raise "invalid checksum"
        end

        dir_path = params[:dir_path]
        unless ::File.directory? dir_path
          raise "dir_path is not a directory: %s" % dir_path
        end
        unless ::File.writable?(dir_path)
          raise "unable to write to directory %s" % dir_path
        end

        f_path = ::File.join dir_path, download_file_info.file_name
        if ::File.exists?(f_path) && !::File.writable?(f_path)
          raise "unable to write to existing file: %s" % f_path
        end

        ::File.binwrite(f_path, download_file_info.body)

        # This can be expensive, we're momentarily copying the body
        map = download_file_info.to_map
        map[:body] = "<omitted>"
        Bkblz::V1::Model::FileDownload.new map
      end
    end
  end
end
