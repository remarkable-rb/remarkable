module Remarkable
  # This helper deals with Remarkable matchers and macros inclusion.
  #
  def self.include_matchers!(matchers_base, klass)
    klass.class_eval do
      include matchers_base::Matchers if defined? matchers_base::Matchers
      extend  matchers_base::Macros   if defined? matchers_base::Macros
    end
  end
end

dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable-core', 'version')
require File.join(dir, 'remarkable-core', 'base')
