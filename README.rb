=begin

tldr:
$ gem install bkblz
$ bkblz help

More...

This is the bkblz Ruby gem, a library for the Backblaze B2 cloud
storage API: https://www.backblaze.com/b2/docs/

Currently the gem supports the following V1 API calls:

  * b2_authorize_account
  * b2_create_bucket
  * b2_delete_bucket
  * b2_delete_file_version
  * b2_get_file_info
  * b2_list_buckets
  * b2_list_file_names
  * b2_list_file_versions
  * b2_upload_file
  * b2_download_file_by_id
  * b2_download_file_by_name

Run `ruby README.rb` for a working demo, but first add your
application key and account id in the slots below.

Or `gem install bkblz` to begin. After install try `bkblz -h` to use
the CLI

=end

$: << 'lib'
require 'bkblz'

Bkblz.configure do |config_map|
  config_map.merge!(
    :application_key => "!!! API KEY !!!",
    :account_id => "!!! ACCOUNT ID !!!",
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

def run_readme
  Bkblz.log.info do <<-EOS
  # Using the config above, create an authorized session. All
  # requests will run in the context of this session. See
  # +Bkblz::V1::Session#authorize+.
  EOS
  end
  Bkblz::V1::Session.authorize Bkblz.config do |session|
    Bkblz.log.info "API session => #{session}"

    Bkblz.log.info do <<-EOS
    # First try to find an existing bucket named my-test-bucket,
    # we'll use that if it exists. All requests in a session are sent
    # through the session so that the request object gets access to the
    # auth credentials.
    EOS
    end
    buckets = session.send(Bkblz::V1::ListBucketsRequest.new).buckets
    Bkblz.log.info "bucket list => #{buckets}"

    new_bucket_name = "bkblz-readme-bucket"
    bucket = buckets.find { |b| b.bucket_name == new_bucket_name  }

    Bkblz.log.info do <<-EOS
    # Otherwise create a new my-test-bucket
    EOS
    end

    begin
      unless bucket
        bucket = Bkblz::V1::Model::Bucket.new \
                                            :bucket_name => new_bucket_name,
        :bucket_type => "allPrivate",
        :account_id => session.account_id

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
        bucket = session.send(request).to_model
        Bkblz.log.info "created bucket => #{bucket}"
      end

      Bkblz.log.info do <<-EOS
      # Uploading a file begins with getting a dynamic URL from the API.
      EOS
      end
      upload_auth = session.send(
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

        upload_file_info = session.send(
          Bkblz::V1::UploadFileRequest.new upload_auth, body, file_name,
                                           content_type, Time.now.to_i * 1000).to_model
        Bkblz.log.info "uploaded file => #{upload_file_info.file_name}"
      end

      Bkblz.log.info do <<-EOS
      # We uploaded 5 files above, here we'll read back out
      # metadata from the first 2 files in the bucket.
      EOS
      end
      list_files_response = session.send(
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
        list_files_response = session.send list_files_response.next_request 100
        bucket_files_info.concat list_files_response.files
        Bkblz.log.info "next N files => #{list_files_response.files.map(&:file_name).join "\n"}"
      end

      Bkblz.log.info do <<-EOS
      # Files can also be listed by name.
      EOS
      end
      list_files_response = session.send(
        Bkblz::V1::ListFileNamesRequest.new bucket, 10)
      bucket_files_info = list_files_response.files
      Bkblz.log.info "files by name => #{bucket_files_info.map(&:file_name).join "\n"}"

      Bkblz.log.info do <<-EOS
      # Files can be downloaded by file name
      EOS
      end
      file_name = bucket_files_info.first.file_name
      file_name_download = session.send(
        Bkblz::V1::DownloadFileByNameRequest.new bucket, file_name).to_model
      Bkblz.log.info file_name_download
      Bkblz.log.info "file body: #{file_name_download.body}"

      Bkblz.log.info do <<-EOS
      # Files can also be downloaded by file id
      EOS
      end
      file_info = bucket_files_info[1]
      file_id_download = session.send(
        Bkblz::V1::DownloadFileByIdRequest.new file_info).to_model
      Bkblz.log.info file_id_download
      Bkblz.log.info "file body: #{file_id_download.body}"

      Bkblz.log.info do <<-EOS
      # File byte ranges can also be downloaded
      EOS
      end
      bytes = (2..8)
      byte_range_download = session.send(
        Bkblz::V1::DownloadFileByNameRequest.new bucket, file_name, bytes).to_model
      Bkblz.log.info "file bytes: #{byte_range_download.body}"
    rescue => e
      Bkblz.log.error "there was an error: #{e}"
      Bkblz.log.error e.backtrace.join "\n"
      Bkblz.log.warn "cleaning up the bucket"
    ensure
      clear_the_bucket session, bucket
    end
  end
end

def clear_the_bucket(session, bucket)
  list_files_response = session.send(
    Bkblz::V1::ListFileVersionsRequest.new bucket)
  bucket_files_info = list_files_response.files

  Bkblz.log.info do <<-EOS
  # Delete all the files in the bucket that we added. This is
  # a service requirement to deleting a bucket.
  EOS
  end
  bucket_files_info.each do |file_info|
    request = Bkblz::V1::DeleteFileVersionRequest.new file_info
    delete_file_version_response = session.send request
    Bkblz.log.info "deleted file => #{delete_file_version_response.to_model.file_name}"
  end

  Bkblz.log.info do <<-EOS
  # Finally, delete the bucket.
  EOS
  end
  request = Bkblz::V1::DeleteBucketRequest.new bucket
  delete_bucket_response = session.send request
  Bkblz.log.info "deleted bucket => #{bucket.bucket_name}/#{bucket.bucket_id}"
end

run_readme
