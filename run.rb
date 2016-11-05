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

Backblaze::Api::Session.run_authorized Backblaze.config do |api_session|
  buckets = api_session.send(Backblaze::Api::ListBucketsRequest.new).buckets

  bucket = buckets.select { |b| b.bucket_name == "my-test-bucket" }.first
  unless bucket
    bucket = Backblaze::Model::Bucket.new \
      :bucket_name => "my-test-bucket",
      :bucket_type => "allPrivate",
      :account_id => api_session.account_id

    request = Backblaze::Api::CreateBucketRequest.new bucket
    Backblaze.log.info "created bucket => #{bucket}"
    bucket = api_session.send(request).to_model
  end

  Backblaze.log.info "backblaze bucket => #{bucket}"
  upload_auth = api_session.send(
    Backblaze::Api::GetUploadUrlRequest.new bucket.bucket_id).to_model

  2.times do |i|
    body = "some text #{i}"
    file_name = "some_text_#{i}.txt"
    content_type = nil
    upload_file_info = api_session.send(
      Backblaze::Api::UploadFileRequest.new upload_auth, body, file_name,
                                            content_type, Time.now.to_i * 1000).to_model
    Backblaze.log.info "uploaded file => #{upload_file_info}"
  end

  # List through all files in the bucket
  list_files_response = api_session.send(
    Backblaze::Api::ListFileVersionsRequest.new bucket, 5)
  bucket_files_info = list_files_response.files
  Backblaze.log.info "files => #{bucket_files_info.join "\n"}"

  # Read all paginated requests
  while list_files_response.has_more?
    list_files_response = api_session.send list_files_response.next 100
    bucket_files_info = list_files_response.files
    Backblaze.log.info "files => #{bucket_files_info.join "\n"}"
  end

  delete = Backblaze::Api::DeleteBucketRequest.new bucket
  Backblaze.log.info "deleted bucket => #{bucket}"
end
