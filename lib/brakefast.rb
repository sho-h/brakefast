require "active_support/core_ext/module/delegation"
require 'set'
require 'uniform_notifier'
require 'brakefast/dependency'

module Brakefast
  extend Dependency

  autoload :Rack, 'brakefast/rack'
  autoload :Notification, 'brakefast/notification'
  autoload :Detector, 'brakefast/detector'
  autoload :NotificationCollector, 'brakefast/notification_collector'

  BRAKEFAST_DEBUG = 'BRAKEFAST_DEBUG'.freeze
  TRUE = 'true'.freeze

  if defined? Rails::Railtie
    class BrakefastRailtie < Rails::Railtie
      initializer "brakefast.configure_rails_initialization" do |app|
        app.middleware.use Brakefast::Rack
      end
    end
  end

  class << self
    attr_writer :enable, :errors_enable, :generic_warnings_enable, :controller_warnings_enable, :model_warnings_enable, :stacktrace_includes
    attr_reader :notification_collector, :whitelist
    attr_accessor :add_footer

    available_notifiers = UniformNotifier::AVAILABLE_NOTIFIERS.map { |notifier| "#{notifier}=" }
    available_notifiers << { :to => UniformNotifier }
    delegate *available_notifiers

    def raise=(should_raise)
      UniformNotifier.raise=(should_raise ? Notification::UnoptimizedQueryError : false)
    end

    DETECTORS = [ Brakefast::Detector::ControllerWarnings,
                  Brakefast::Detector::ModelWarnings,
                  Brakefast::Detector::GenericWarnings ]

    def enable=(enable)
      @enable = @errors_enable = @generic_warnings_enable = @controller_warnings_enable = @model_warnings_enable = enable
      reset_whitelist if enable?
    end

    def enable?
      !!@enable
    end

    def errors_enable?
      self.enable? && !!@errors_enable
    end

    def generic_warnings_enable?
      self.enable? && !!@generic_warnings_enable
    end

    def controller_warnings_enable?
      self.enable? && !!@controller_warnings_enable
    end

    def model_warnings_enable?
      self.enable? && !!@model_warnings_enable
    end

    def stacktrace_includes
      @stacktrace_includes || []
    end

    def add_whitelist(options)
      @whitelist[options[:type]][options[:class_name].classify] ||= []
      @whitelist[options[:type]][options[:class_name].classify] << options[:association].to_sym
    end

    def get_whitelist_associations(type, class_name)
      Array(@whitelist[type][class_name])
    end

    def reset_whitelist
      @whitelist = {:n_plus_one_query => {}, :unused_eager_loading => {}, :counter_cache => {}}
    end

    def brakefast_logger=(active)
      if active
        require 'fileutils'
        root_path = "#{rails? ? Rails.root.to_s : Dir.pwd}"
        FileUtils.mkdir_p(root_path + '/log')
        brakefast_log_file = File.open("#{root_path}/log/brakefast.log", 'a+')
        brakefast_log_file.sync = true
        UniformNotifier.customized_logger = brakefast_log_file
      end
    end

    def debug(title, message)
      puts "[Brakefast][#{title}] #{message}" if ENV[BRAKEFAST_DEBUG] == TRUE
    end

    def start_request
      Thread.current[:brakefast_start] = true
      Thread.current[:brakefast_notification_collector] = Brakefast::NotificationCollector.new
    end

    def end_request
      Thread.current[:brakefast_start] = nil
      Thread.current[:brakefast_notification_collector] = nil
    end

    def start?
      enable? && Thread.current[:brakefast_start]
    end

    def notification_collector
      Thread.current[:brakefast_notification_collector]
    end

    def notification?
      return unless start?
      notification_collector.notifications_present?
    end

    def gather_inline_notifications
      responses = []
      for_each_active_notifier_with_notification do |notification|
        responses << notification.notify_inline
      end
      responses.join( "\n" )
    end

    def perform_out_of_channel_notifications(env = {})
      for_each_active_notifier_with_notification do |notification|
        notification.url = env['REQUEST_URI']
        notification.notify_out_of_channel
      end
    end

    def footer_info
      info = []
      notification_collector.collection.each do |notification|
        info << notification.short_notice
      end
      info
    end

    def warnings
      notification_collector.collection.inject({}) do |warnings, notification|
        warning_type = notification.class.to_s.split(':').last.tableize
        warnings[warning_type] ||= []
        warnings[warning_type] << notification
        warnings
      end
    end

    def profile
      if Brakefast.enable?
        begin
          Brakefast.start_request

          yield

          Brakefast.perform_out_of_channel_notifications if Brakefast.notification?
        ensure
          Brakefast.end_request
        end
      end
    end

    private
      def for_each_active_notifier_with_notification
        UniformNotifier.active_notifiers.each do |notifier|
          notification_collector.collection.each do |notification|
            notification.notifier = notifier
            yield notification
          end
        end
      end
  end
end
