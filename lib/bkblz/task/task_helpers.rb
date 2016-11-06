module Bkblz
  module Task

    MissingBucketError = Class.new Bkblz::BaseError

    module TaskHelpers

      def find_bucket_by_name(session, bucket_name)
        buckets = session.send(Bkblz::V1::ListBucketsRequest.new).buckets
        bucket = buckets.find do |bucket|
          bucket.bucket_name == bucket_name
        end
        raise MissingBucketError, bucket_name unless bucket
        bucket
      end

    end
  end
end
