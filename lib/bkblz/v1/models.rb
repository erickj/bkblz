module Bkblz
  module V1
    module Model

      # Returned by list_buckets, create_bucket, delete_bucket
      Bucket = Model.define :account_id, :bucket_id, :bucket_name, :bucket_type

      # Returned by list_file_versions
      File = Model.define *[
        :action, :content_length, :file_id, :file_name, :size, :upload_timestamp
      ]

      # Returned by download_file_by_name and download_file_by_id
      FileDownload = Model.define *[
        :body, :content_length, :content_type, :file_id, :file_name, :sha1, :x_bz_info
      ]

      # Returned by upload_file
      FileInfo = Model.define *[
        :account_id, :bucket_id, :content_length, :content_sha1, :content_type,
        :file_id, :file_info, :file_name
      ]

      # Returned by delete_file_version
      PartialFileInfo = Model.define :file_id, :file_name

      # Returned by get_upload_url
      UploadAuth = Model.define :bucket_id, :upload_url, :authorization_token

      # Possibly returned by any request
      Error = Model.define :status, :code, :message
    end
  end
end
