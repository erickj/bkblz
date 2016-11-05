module Backblaze
  module CoreExt
    refine String do
      def underscore
        uncamelify = self.gsub /[a-z\W][A-Z]/ do |m|
          m.gsub /(^.)/, '\1_'
        end
        uncamelify.downcase.gsub(/[^a-z0-9]+/, '_')
      end

      def demodulize
        self.split('::').last
      end
    end
  end
end
