require 'remarkable/active_record/helpers'
%w( database associations validations ).each do |folder|
  Dir[File.join(File.dirname(__FILE__), "macros", folder, '*')].each do |file|
    require file
  end
end

module Spec
  module Rails
    module Matchers
      include Remarkable::Private
      include Remarkable::ActiveRecord::Helpers
    end
  end
end

Spec::Rails::Matchers.send(:include, Remarkable::Syntax::RSpec)

Spec::Example::ExampleGroupMethods.send(:include, Remarkable::Private)
Spec::Example::ExampleGroupMethods.send(:include, Remarkable::ActiveRecord::Helpers)
Spec::Example::ExampleGroupMethods.send(:include, Remarkable::Syntax::Shoulda)
