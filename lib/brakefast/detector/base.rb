require 'forwardable'

module Brakefast
  module Detector
    class Base
      extend Forwardable

      attr_reader :vulnerability
      def_delegator :@vulnerability, :method, :target_method_name
      def_delegator :@vulnerability, :message, :message
      def_delegator :@vulnerability, :file, :file
      def_delegator :@vulnerability, :line, :line

      @@type2klass = {
      }

      class << self
        def create_instance(type, *args)
          @@type2klass[type].new(*args)
        end

        def register_detector(type)
          @@type2klass[type] = self
        end

        def types
          @@type2klass.keys
        end
      end

      def initialize(vulnerability)
        @vulnerability = vulnerability
      end

      def set_detector_module
        raise "override me"
      end

      def target_module_name
        raise "override me"
      end

      private

      def create_module_name(s)
        s.to_s.gsub("::", "__") + "BrakefastHook"
      end

      def create_hook
        name = create_module_name(target_module_name)
        if Brakefast.const_defined?(name)
          mod = Brakefast.const_get(name)
        else
          mod = Module.new
        end

        yield(mod)

        # prepend once and create module once only.
        if mod.name.nil?
          Brakefast.const_set(name, mod)
          ::Object.const_get(target_module_name).class_eval %Q{
            prepend Brakefast::#{name}
          }
        end
      end
    end
  end
end
