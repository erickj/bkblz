require_relative "bkblz/config"
require_relative "bkblz/logger"

module Bkblz

  BaseError = Class.new ::StandardError

  class << self
    def configure(&block)
      @config = Bkblz::Config.configure @config, &block
      config_changed
    end

    def config
      unless @config
        @config = Bkblz::Config.configure
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
      @logger = Bkblz::Logger.configure config
    end
  end
end

require "bkblz/all"
