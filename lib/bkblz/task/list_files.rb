module Bkblz
  module Task
    class ListFiles < BaseTask

      task_param :start_at
      task_param :limit, :default => 100
      task_param :all_versions
      task_param :bucket_name, :required => true

      def run_internal(session, params)
        bucket = find_bucket_by_name session, params[:bucket_name]

        if params[:all_versions]
          session.send Bkblz::V1::ListFileVersionsRequest.new bucket, params[:limit]
        else
          session.send Bkblz::V1::ListFileNamesRequest.new(
                         bucket, params[:limit], params[:start_at])
        end
      end
    end
  end
end
