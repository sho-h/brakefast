module Brakefast
  module Detector
    autoload :Base, 'brakefast/detector/base'
    autoload :ControllerWarnings, 'brakefast/detector/controller_warnings'
    autoload :ModelWarnings, 'brakefast/detector/model_warnings'
    autoload :GenericWarnings, 'brakefast/detector/generic_warnings'
  end
end
