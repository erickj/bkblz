require 'digest/sha1'

module Bkblz
  module Task
    class DownloadFile < BaseTask

      task_param :dir_path, :required => true

      # for downalod by id
      task_param :file_id

      # for download by name
      task_param :bucket_name
      task_param :file_name
      task_param :use_filename

      def run_internal(session, params)
        download_file_info = if params[:use_filename]
                               download_by_name(session, params)
                             else
                               download_by_id(session, params)
                             end

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

      def download_by_name(session, params)
        raise 'missing file name' unless params[:file_name]
        raise 'missing bucket name' unless params[:bucket_name]

        bucket = find_bucket_by_name session, params[:bucket_name]
        file = params[:file_name]
        session.send(
          Bkblz::V1::DownloadFileByNameRequest.new bucket, file).to_model
      end

      def download_by_id(session, params)
        raise 'missing file id' unless params[:file_id]

        partial_file_info =
          Bkblz::V1::Model::PartialFileInfo.new :file_id => params[:file_id]
        session.send(
          Bkblz::V1::DownloadFileByIdRequest.new partial_file_info).to_model
      end
    end
  end
end
