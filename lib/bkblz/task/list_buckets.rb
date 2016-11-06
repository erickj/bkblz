module Bkblz
  module Task
    class ListBuckets < BaseTask

      def run_internal(session, params)
        session.send(Bkblz::V1::ListBucketsRequest.new).buckets
      end

    end
  end
end
