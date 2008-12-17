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



# 
# 
# 
# 
# module Spec
#   module Rails
#     module Matchers
#       include Remarkable::Controller::Helpers
#     end
#   end
# end
# 
# Spec::Rails::Matchers.send(:include, Remarkable::Controller::Syntax::RSpec)
# Spec::Example::ExampleGroupMethods.send(:include, Remarkable::Controller::Syntax::Shoulda)
