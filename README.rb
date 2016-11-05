$: << 'lib'
require 'all'

# Step 1, configure some defaults, see Backblaze::Config for
# details. This is where to set the account_id and application_key.
Backblaze.configure do |config_map|
  config_map.merge!(
    :application_key => "!!! APPLICATION KEY !!!",
    :account_id => "!!! ACCOUNT ID !!!",
    :debug_http => false,
    :log_level => :info
  )
end

# Step 2, using the config above, create an authorized session. All
# requests will run in the context of this session. See
# +Backblaze::V1::Session#run_authorized+.
Backblaze::V1::Session.authorize Backblaze.config do |api_session|

  # Step 3, first try to find an existing bucket named my-test-bucket,
  # we'll use that if it exists. All requests in a session are sent
  # through the session so that the request object gets access to the
  # auth credentials.
  buckets = api_session.send(Backblaze::V1::ListBucketsRequest.new).buckets
  bucket = buckets.select { |b| b.bucket_name == "my-test-bucket" }.first

  # Step 4, otherwise create a new my-test-bucket
  unless bucket
    # Backblaze models are just named wrappers with dynamic methods
    # around the JSON responses provided back from the Backblaze
    # API. See lib/backblaze/v1/models.rb for a list of defined API
    # objects. See Backblaze::V1::Model::Base for how it work.
    bucket = Backblaze::V1::Model::Bucket.new \
      :bucket_name => "my-test-bucket",
      :bucket_type => "allPrivate",
      :account_id => api_session.account_id

    # Step 5, pass a model to the CreateBucketRequest
    request = Backblaze::V1::CreateBucketRequest.new bucket

    # Response
    bucket = api_session.send(request).to_model
    Backblaze.log.info "created bucket => #{bucket.bucket_name}/#{bucket.bucket_id}"
  end

  # Step 6, uploading a file begins with getting a dynamic URL from the API.
  upload_auth = api_session.send(
    Backblaze::V1::GetUploadUrlRequest.new bucket.bucket_id).to_model
  Backblaze.log.info "upload file URL => #{upload_auth.upload_url}"

  5.times do |i|
    body = "some text #{i}"
    file_name = "some_text_#{i}.txt"
    content_type = nil

    # Step 7, use the upload_auth model (a
    # Backblaze::V1::Model::UploadAuth) to upload some files.
    upload_file_info = api_session.send(
      Backblaze::V1::UploadFileRequest.new upload_auth, body, file_name,
                                            content_type, Time.now.to_i * 1000).to_model
    Backblaze.log.info "uploaded file => #{upload_file_info.file_name}"
  end

  # Step 8, we uploaded 5 files above, here we'll read back out
  # metadata from the first 2 files in the bucket.
  list_files_response = api_session.send(
    Backblaze::V1::ListFileVersionsRequest.new bucket, 2)
  bucket_files_info = list_files_response.files
  Backblaze.log.info "first 2 files => #{bucket_files_info.map(&:file_name).join "\n"}"

  # Step 9, the response object returned object is a
  # Backblaze::Api::PaginatedResponse. Use its +has_more?+ and
  # +next_request+ methods to page through more results.
  while list_files_response.has_more?
    list_files_response = api_session.send list_files_response.next_request 100
    bucket_files_info.concat list_files_response.files
    Backblaze.log.info "next N files => #{list_files_response.files.map(&:file_name).join "\n"}"
  end

  # Step 10, delete all the files in the bucket that we added. This is
  # a service requirement to deleting a bucket.
  bucket_files_info.each do |file_info|
    request = Backblaze::V1::DeleteFileVersionRequest.new file_info
    delete_file_version_response = api_session.send request
    Backblaze.log.info "deleted file => #{delete_file_version_response.to_model.file_name}"
  end

  # Step 11, delete the bucket.
  request = Backblaze::V1::DeleteBucketRequest.new bucket
  delete_bucket_response = api_session.send request
  Backblaze.log.info "deleted bucket => #{bucket.bucket_name}/#{bucket.bucket_id}"

  # Fin
end
