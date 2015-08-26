module Brakefast
  module Notification
    class ModelWarnings < Base
      # TODO: move to base?
      def title
        "vulnerability found: ModelWarnings"
      end

      def body
        "#{message} - #{path}:#{line}"
      end
    end
  end
end
