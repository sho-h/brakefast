module Brakefast
  module Notification
    class ControllerWarnings < Base
      # TODO: move to base?
      def title
        "vulnerability found: ControllerWarnings"
      end

      def body
        "#{message} - #{path}:#{line}"
      end
    end
  end
end
