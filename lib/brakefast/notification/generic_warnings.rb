module Brakefast
  module Notification
    class GenericWarnings < Base
      # TODO: move to base?
      def title
        "vulnerability found: GenericWarnings"
      end

      def body
        "#{message} - #{path}:#{line}"
      end
    end
  end
end
