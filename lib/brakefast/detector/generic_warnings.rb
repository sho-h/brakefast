module Brakefast
  module Detector
    class GenericWarnings < Base
      register_detector :generic_warnings

      def set_detector_module
        if target_module_name && target_method_name
          create_hook do |mod|
            if md = /\A(#{target_module_name}|s\(:self\))\.(.*)/.match(target_method_name)
              m = mod.const_get(:ClassMethods)
              name = md[2]
            else
              m = mod
              name = target_method_name
            end

            m.module_eval %Q{
              def #{name}(*args)
                n = Brakefast::Notification::GenericWarnings.new(self, '#{escaped_message}',
                                                                 '#{file}','#{line}')
                Brakefast.notification_collector.add(n)
                super
              end
            }
          end
        end
      end

      def target_module_name
        vulnerability.class
      end
    end
  end
end
