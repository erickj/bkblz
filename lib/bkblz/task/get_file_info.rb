module Bkblz
  module Task
    class GetFileInfo < BaseTask

      task_param :file_id, :required => true

      def run_internal(session, params)
        session.send(Bkblz::V1::GetFileInfoRequest.new(params[:file_id]))
          .to_model
      end

    end
  end
end
