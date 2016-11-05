module Backblaze
  module Api
    class GetUploadUrl < Request
      # require 'json'
      # require 'net/http'

      # api_url = "" # Provided by b2_authorize_account
      # account_authorization_token = "" # Provided by b2_authorize_account
      # bucket_id = "" # The ID of the bucket you want to upload your file to
      # uri = URI("#{api_url}/b2api/v1/b2_get_upload_url")
      # req = Net::HTTP::Post.new(uri)
      # req.add_field("Authorization","#{account_authorization_token}")
      # req.body = "{\"bucketId\":\"#{bucket_id}\"}"
    end
  end
end
