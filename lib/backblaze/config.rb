module Backblaze

  class Config

    CONFIG_VARS = {
      :application_key => '',
      :account_id => '',
      :debug_http => false,

      :log_device => :stderr, # [:stdout, :stderr, :devnull, path, fd]
      :log_level => :warn, # [:debug, :info, :warn, :error, :fatal, (-6..-1)]
      :log_colorize => true
    }.freeze

    attr_reader *CONFIG_VARS.keys, :config_map

    def initialize(**config_map)
      config_map.each do |k,v|
        # allows attr_reader methods from CONFIG_VAR to work
        instance_variable_set :"@#{k}", v
      end

      @config_map = config_map
    end

    class << self
      def configure(config=nil, &block)
        map = config ? config.config_map : CONFIG_VARS.dup
        yield map if block_given?
        Config.new map
      end
    end

  end
end
