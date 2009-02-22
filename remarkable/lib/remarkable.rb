# Remarkable core module
module Remarkable
  @@registered_subjects = []

  # Helper that includes required Remarkable modules into the given klass.
  #
  def self.include_matchers!(base, klass)
    # Add Remarkable core modules
    klass.send :extend,  Remarkable::Macros

    klass.send :include, base::Matchers if defined?(base::Matchers)
    klass.send :extend,  base::Matchers if defined?(base::Matchers)
    klass.send :extend,  base::Macros   if defined?(base::Macros)
  end

  # Register a block that will be called when the specified condition is met.
  #
  # This is used when the matcher subject is not the same as the current rspec
  # subject. The condition receives as parameter a matcher and the block given
  # is evaluated in the spec instance scope.
  #
  def self.register_subject(condition, &block)
    @@registered_subjects.unshift [ condition, block ]
  end

  # Return the registered subjects. This method is called in should and
  # should_not methods.
  #
  def self.registered_subjects
    @@registered_subjects
  end
end

# Load rspec
begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'spec'
  require 'spec'
end

# Load core files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable', 'version')
require File.join(dir, 'remarkable', 'i18n')
require File.join(dir, 'remarkable', 'dsl')
require File.join(dir, 'remarkable', 'messages')

require File.join(dir, 'remarkable', 'base')
require File.join(dir, 'remarkable', 'macros')

require File.join(dir, 'remarkable', 'rspec')
require File.join(dir, 'remarkable', 'core_ext', 'array')
# Add Remarkable default locale file
Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')
