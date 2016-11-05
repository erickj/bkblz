$: << 'lib'
require 'all'

Backblaze.configure do |config_map|
  config_map.merge!(
    :application_key => "***REMOVED***",
    :account_id => "***REMOVED***",
    :debug_http => true,
    :log_level => :debug
  )
end

Backblaze::Api::Session.run_authorized Backblaze.config do |session|
  buckets = session.send_request(Backblaze::Api::ListBucketsRequest.new).buckets

  bucket = buckets.select { |b| b.bucket_name == "my-test-bucket" }.first
  unless bucket
    bucket = Backblaze::Model::Bucket.new \
      :bucket_name => "my-test-bucket",
      :bucket_type => "allPrivate",
      :account_id => session.account_id

    request = Backblaze::Api::CreateBucketRequest.new bucket
    Backblaze.log.info "created bucket => #{bucket}"
    bucket = session.send_request(request).to_model
  end

  Backblaze.log.info "backblaze bucket => #{bucket}"
  upload_auth = session.send_request(
    Backblaze::Api::GetUploadUrlRequest.new bucket.bucket_id).to_model

  upload_file_info = session.send_request(
    Backblaze::Api::UploadFileRequest.new upload_auth, "some text", "some_text.txt",
    nil, Time.now.to_i * 1000).to_model
  Backblaze.log.info "uploaded file => #{upload_file_info}"

  delete_request = Backblaze::Api::DeleteBucketRequest.new bucket
  Backblaze.log.info "deleted bucket => #{bucket}"
end
