module Backblaze
  module Api
    class ErrorResponse < Response

      response_model Model::Error

      ERROR_TYPE = {
        400 => :BAD_REQUEST,
        401 => :UNAUTHORIZED,
        403 => :FORBIDDEN,
        408 => :REQUEST_TIMEOUT,
        429 => :TOO_MANY_REQUESTS,
        500 => :INTERNAL_ERROR,
        503 => :SERVICE_UNAVAILABLE
      }

      def message
        model = self.to_model
        error_type = ERROR_TYPE[model.status]
        "[#{model.status}:#{error_type}:#{model.code}] #{model.message}"
      end
    end
  end
end
