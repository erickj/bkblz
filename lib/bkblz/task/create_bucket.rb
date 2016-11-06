module Bkblz
  module Task
    class CreateBucket < BaseTask

      DuplicateBucketError = Class.new Bkblz::BaseError

      task_param :bucket_name, :required => true
      task_param :bucket_type

      def run_internal(session, params)
        bucket_fields = {
          :account_id => session.account_id,
          :bucket_type => "allPrivate"
        }.merge params
        bucket = Bkblz::V1::Model::Bucket.new bucket_fields

        session.send(Bkblz::V1::CreateBucketRequest.new bucket).to_model
      end

    end
  end
end
