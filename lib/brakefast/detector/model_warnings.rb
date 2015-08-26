module Brakefast
  module Detector
    class ModelWarnings < Base
      register_detector :model_warnings

      def set_detector_module
        if target_module_name && target_method_name
          mod = Module.new
          mod.module_eval %Q{
            def #{target_method_name}
              s = "vulnerability found in #{file}:#{line} - #{message}"
              Thread.current[:brakefast_notifications] << s
              super
            end
          }

          create_hook(target_module_name, mod)
        end
      end

      def target_module_name
        vulnerability.model
      end
    end
  end
end
