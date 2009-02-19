# Load Remarkable (whick loads rspec)
unless Object.const_defined?('Remarkable')
  begin
    require 'remarkable'
  rescue LoadError
    require 'rubygems'
    gem 'remarkable'
    require 'remarkable'
  end
end

module Remarkable
  module ActiveRecord
  end
end

# Load Remarkable ActiveRecord files
dir = File.dirname(__FILE__)

# By default, ActiveRecord matchers are not included in any example group.
# The responsable for this is RemarkableRails. If you are using ActiveRecord
# without Rails, put the line below in your spec_helper to include ActiveRecord
# matchers into rspec globally.
# Remarkable.include_matchers!(Remarkable::ActiveRecord, Spec::Example::ExampleGroup)
