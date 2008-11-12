require "remarkable/controller/helpers"
Dir[File.join(File.dirname(__FILE__), "macros", '*')].each do |file|
  require file
end

module Spec
  module Rails
    module Matchers
      include Remarkable::Controller::Helpers
    end
  end
end

Spec::Rails::Matchers.send(:include, Remarkable::Syntax::RSpec)
Spec::Example::ExampleGroupMethods.send(:include, Remarkable::Syntax::Shoulda)
