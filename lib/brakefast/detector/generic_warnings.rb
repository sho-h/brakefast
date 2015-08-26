module Brakefast
  module Detector
    class GenericWarnings < Base
      register_detector :generic_warnings

      def set_detector_module
        if target_module_name && target_method_name
          mod = Module.new
          mod.module_eval %Q{
            def #{target_method_name}
              n = Brakefast::Notification::GenericWarnings.new(self, '#{message}',
                                                               '#{file}','#{line}')
              Brakefast.notification_collector.add(n)
              super
            end
          }

          create_hook(target_module_name, mod)
        end
      end

      def target_module_name
        vulnerability.class
      end
    end
  end
end
