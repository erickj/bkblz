# Run `ruby README.rb` for a working demo, but first add your
# application key and account id in the slots below.

# Or `gem install bkblz` to begin. After install try `bkblz -h` to use
# the CLI

$: << 'lib'
require 'bkblz'

Bkblz.configure do |config_map|
  config_map.merge!(
    :application_key => "*** API KEY ***",
    :account_id => "*** ACCOUNT ID ***",
    :debug_http => false,
    :log_level => :info # change this to :debug for more info
  )
end

Bkblz.log.info do <<-EOS
# The block above configures some defaults (including the
# logger, which is why this is after the configure block), see
# Bkblz::Config for details. This is where to set the account_id
# and application_key.
EOS
end

if Bkblz.config.account_id.match /!!!/
  Bkblz.log.error "you didn't fill in your credentials, read the comments"
  exit 1
end

Bkblz.log.info do <<-EOS
# Using the config above, create an authorized session. All
# requests will run in the context of this session. See
# +Bkblz::V1::Session#authorize+.
EOS
end
Bkblz::V1::Session.authorize Bkblz.config do |api_session|
  Bkblz.log.info "API session => #{api_session}"

  Bkblz.log.info do <<-EOS
  # First try to find an existing bucket named my-test-bucket,
  # we'll use that if it exists. All requests in a session are sent
  # through the session so that the request object gets access to the
  # auth credentials.
  EOS
  end
  buckets = api_session.send(Bkblz::V1::ListBucketsRequest.new).buckets
  bucket = buckets.select { |b| b.bucket_name == "my-test-bucket" }.first
  Bkblz.log.info "bucket list => #{buckets}"

  Bkblz.log.info do <<-EOS
  # Otherwise create a new my-test-bucket
  EOS
  end
  unless bucket
    bucket = Bkblz::V1::Model::Bucket.new \
      :bucket_name => "my-test-bucket",
      :bucket_type => "allPrivate",
      :account_id => api_session.account_id

    Bkblz.log.info do <<-EOS
    # Pass a model to the CreateBucketRequest,
    # models are just named wrappers with dynamic methods
    # around the JSON responses provided back from the Bkblz
    # API. See lib/bkblz/v1/models.rb for a list of defined API
    # objects. See Bkblz::V1::Model::Base for how it work.
    EOS
    end
    request = Bkblz::V1::CreateBucketRequest.new bucket
    Bkblz.log.info "bucket model => #{bucket}"

    # Bkblz::V1::Response objects are returned from +send+. Some
    # provide a to_model method if they declare the +response_model+
    # in the class definition.
    bucket = api_session.send(request).to_model
    Bkblz.log.info "created bucket => #{bucket.bucket_name}/#{bucket.bucket_id}"
  end

  Bkblz.log.info do <<-EOS
  # Uploading a file begins with getting a dynamic URL from the API.
  EOS
  end
  upload_auth = api_session.send(
    Bkblz::V1::GetUploadUrlRequest.new bucket.bucket_id).to_model
  Bkblz.log.info "upload file URL => #{upload_auth.upload_url}"


  Bkblz.log.info do <<-EOS
  # Use the upload_auth model (a
  # Bkblz::V1::Model::UploadAuth) to upload some files.
  EOS
  end
  5.times do |i|
    body = "some text #{i}"
    file_name = "some_text_#{i}.txt"
    content_type = nil

    upload_file_info = api_session.send(
      Bkblz::V1::UploadFileRequest.new upload_auth, body, file_name,
                                           content_type, Time.now.to_i * 1000).to_model
    Bkblz.log.info "uploaded file => #{upload_file_info.file_name}"
  end

  Bkblz.log.info do <<-EOS
  # We uploaded 5 files above, here we'll read back out
  # metadata from the first 2 files in the bucket.
  EOS
  end
  list_files_response = api_session.send(
    Bkblz::V1::ListFileVersionsRequest.new bucket, 2)
  bucket_files_info = list_files_response.files
  Bkblz.log.info "first 2 files => #{bucket_files_info.map(&:file_name).join "\n"}"

  Bkblz.log.info do <<-EOS
  # The response object returned object is a
  # Bkblz::Api::PaginatedResponse. Use its +has_more?+ and
  # +next_request+ methods to page through more results.
  EOS
  end
  while list_files_response.has_more?
    list_files_response = api_session.send list_files_response.next_request 100
    bucket_files_info.concat list_files_response.files
    Bkblz.log.info "next N files => #{list_files_response.files.map(&:file_name).join "\n"}"
  end

  Bkblz.log.info do <<-EOS
  # Files can also be listed by name.
  EOS
  end
  list_files_response = api_session.send(
    Bkblz::V1::ListFileNamesRequest.new bucket, 10)
  bucket_files_info = list_files_response.files
  Bkblz.log.info "files by name => #{bucket_files_info.map(&:file_name).join "\n"}"

  Bkblz.log.info do <<-EOS
  # Delete all the files in the bucket that we added. This is
  # a service requirement to deleting a bucket.
  EOS
  end
  bucket_files_info.each do |file_info|
    request = Bkblz::V1::DeleteFileVersionRequest.new file_info
    delete_file_version_response = api_session.send request
    Bkblz.log.info "deleted file => #{delete_file_version_response.to_model.file_name}"
  end

  Bkblz.log.info do <<-EOS
  # Finally, delete the bucket.
  EOS
  end
  request = Bkblz::V1::DeleteBucketRequest.new bucket
  delete_bucket_response = api_session.send request
  Bkblz.log.info "deleted bucket => #{bucket.bucket_name}/#{bucket.bucket_id}"
end
