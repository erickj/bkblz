module Bkblz
  module Task

    TaskParamError = Class.new Bkblz::BaseError

    module ClassMethods
      PARAM_SPEC = {
        :name => nil,
        :required => false,
        :default => nil,
        :one_of => nil
      }.freeze

      def run(config, **params)
        task = self.new config
        task.run **params
      end

      def task_param(name, **param_spec)
        if param_spec[:one_of] && !param_spec[:one_of].is_a?(Enumerable)
          raise TaskParamError, "#{name}: :one_of must be enumerable"
        end
        task_params << PARAM_SPEC.merge(param_spec.merge :name => name)
      end

      def task_params
        @task_params ||= []
      end

      def check_params(params)
        task_params.each do |spec|
          name spec[:name]
          value = params[name]

          if spec[:default] && value.nil?
            params[name] = spec[:default]
          end

          check_required name, value, spec
          check_one_of name, value, spec
        end
      end

      def check_required(name, value, spec)
        raise TaskParamError, "[#{name}:required]" if spec[:required] && value.nil?
      end

      def check_one_of(name, value, spec)
        return unless spec[:one_of]
        unless spec[:one_of].include? value
          raise TaskParamError, "[#{name}:one_of] invalid values: #{value}"
        end
      end
    end

    class BaseTask
      extend ClassMethods
      include TaskHelpers

      attr_reader :config, :result

      def initialize(config)
        @config = config
        @result = nil
      end

      def run(task_params)
        BaseTask.check_params task_params

        Bkblz::V1::Session.authorize config do |session|
          @result = run_internal session, task_params
        end
        result
      end

      protected
      def run_internal(session, task_params)
        raise 'not implemented'
      end
    end
  end
end
