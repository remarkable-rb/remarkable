%w( database associations validations ).each do |folder|
  Dir[File.join("lib", "remarkable", "active_record", "macros", folder, '*')].each do |file|
    require file
  end
end

module Spec
  module Rails
    module Matchers
      include Remarkable::Private
    end
  end
end

Spec::Rails::Matchers.send(:include, Remarkable::Syntax::RSpec)
# Spec::Example::ExampleGroupMethods.send(:include, Remarkable::Syntax::Shoulda)
