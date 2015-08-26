module Brakefast
  module Notification
    class Base
      attr_accessor :notifier, :url
      attr_reader :klass, :message, :path, :line

      def initialize(klass, message, path = nil, line = nil)
        @klass = klass
        @message = message
        @path = path
        @line = line
      end

      def title
        raise NoMethodError.new("no method title defined")
      end

      def body
        raise NoMethodError.new("no method body defined")
      end

      def call_stack_messages
        ""
      end

      def whoami
        @user ||= ENV['USER'].presence || (`whoami`.chomp rescue "")
        if @user.present?
          "user: #{@user}"
        else
          ""
        end
      end

      def body_with_caller
        "#{body}\n#{call_stack_messages}\n"
      end

      def notify_inline
        self.notifier.inline_notify(notification_data)
      end

      def notify_out_of_channel
        self.notifier.out_of_channel_notify(notification_data)
      end

      def short_notice
        [whoami.presence, url, title, body].compact.join("  ")
      end

      def notification_data
        {
          :user => whoami,
          :url => url,
          :title => title,
          :body => body_with_caller,
        }
      end
    end
  end
end
