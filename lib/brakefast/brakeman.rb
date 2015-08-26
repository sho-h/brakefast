require 'brakeman'
require 'brakefast/detector'

module Brakefast
  class Brakeman
    def self.run(path)
      tracker = ::Brakeman.run(Rails.root.to_s)
      report = tracker.report.format(:to_hash)
      Brakefast::Detector::Base.types.each do |type|
        next if !Brakefast.public_send("#{type}_enable?")
        report[type].each do |vulnerability|
          detector = Brakefast::Detector::Base.create_instance(type, vulnerability)
          detector.set_detector_module
        end
      end
    end
  end
end
