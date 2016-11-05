module Backblaze
  module Model
    Bucket = Model.define :account_id, :bucket_id, :bucket_name, :bucket_type

    File = Model.define *[
      :action, :content_length, :file_id, :file_name, :size, :upload_timestamp
    ]

    FileInfo = Model.define *[
      :account_id, :bucket_id, :content_length, :content_sha1, :content_type,
      :file_id, :file_info, :file_name
    ]

    UploadAuth = Model.define :bucket_id, :upload_url, :authorization_token
  end
end
