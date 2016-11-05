module Backblaze
  module Api
    class Session

      attr_accessor :config

      def initialize(config)
        @config = config
      end
    end
  end
end
