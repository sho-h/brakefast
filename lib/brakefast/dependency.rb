module Brakefast
  module Dependency
    def rails?
      @rails ||= defined? ::Rails
    end
  end
end
