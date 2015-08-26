module Brakefast
  module Detector
    class ControllerWarnings < Base
      register_detector :controller_warnings

      def set_detector_module
        if target_module_name && target_method_name
          mod = Module.new
          mod.module_eval %Q{
            def #{target_method_name}
              s = "vulnerability found in #{file}:#{line} - #{message}"
              Thread.current[:brakefast_notifications] << s
=begin
              # for debug
              File.open("/tmp/1.log", "a") do |f|
                f.write("vulnerability found in #{e.file}:#{e.line} - #{msg}")
              end
=end
              super
            end
          }

          create_hook(target_module_name, mod)
        end
      end

      def target_module_name
        vulnerability.controller
      end
    end
  end
end
