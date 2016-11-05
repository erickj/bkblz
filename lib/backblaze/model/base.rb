module Backblaze
  module Model

    def self.define(*fields)
      model_klass = Class.new BaseModel
      model_klass.field_accessors *fields
      model_klass
    end

    class BaseModel

      class << self
        def field_accessors(*fields)
          fields.each do |field|
            define_method field do |*args|
              @map[field]
            end
          end
        end
      end

      def initialize(map)
        @map = map
      end

      def to_map
        @map.dup
      end

      def to_s
        "#<%s:%d %s>" % [self.class.name, __id__, @map]
      end
    end
  end
end
