module Brakefast
  module Notification
    autoload :Base, 'brakefast/notification/base'
    autoload :GenericWarnings, 'brakefast/notification/generic_warnings'
    autoload :ControllerWarnings, 'brakefast/notification/controller_warnings'
    autoload :ModelWarnings, 'brakefast/notification/model_warnings'

    class UnoptimizedQueryError < StandardError; end
  end
end
