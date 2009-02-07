require 'remarkable/controller/helpers'
Dir[File.join(File.dirname(__FILE__), "macros", '*.rb')].each do |file|
  require file
end
require 'remarkable/controller/macros'

module Spec
  module Rails
    module Example
      class ControllerExampleGroup
        include Remarkable::Assertions
        include Remarkable::Controller::Matchers
        extend Remarkable::Controller::Macros

        private
        include Remarkable::Private
      end
    end
  end
end
