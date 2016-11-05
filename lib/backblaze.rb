require "backblaze/config"
require "backblaze/logger"

module Backblaze

  BaseError = Class.new ::StandardError

  class << self
    def configure(&block)
      @config = Backblaze::Config.configure @config, &block
      config_changed
    end

    def config
      unless @config
        @config = Backblaze::Config.configure
        config_changed
      end
      @config
    end

    def log
      @logger ||= config_logger
    end

    private
    def config_changed
      @logger = nil
    end

    def config_logger
      @logger = Backblaze::Logger.configure config
    end
  end
end



