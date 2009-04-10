module Remarkable
  module ActionView
  end
end

dir = File.dirname(__FILE__)
require File.join(dir, 'action_view', 'base')

# Load matchers
Dir[File.join(dir, 'action_view', 'matchers', '*.rb')].each do |file|
  require file
end

# Iinclude matchers in Spec::Rails
if defined?(Spec::Rails)
  Remarkable.include_matchers!(Remarkable::ActionView, Spec::Rails::Example::FunctionalExampleGroup)
end

