dir = File.dirname(__FILE__)
require File.join(dir, 'dsl', 'assertions')
require File.join(dir, 'dsl', 'optionals')
require File.join(dir, 'dsl', 'matches')
require File.join(dir, 'dsl', 'callbacks')

module Remarkable
  module DSL
    ATTR_READERS = [ :matcher_arguments, :matcher_optionals, :matcher_assertions,
      :matcher_for_assertions, :before_assert_callbacks, :after_initialize_callbacks
    ] unless self.const_defined?(:ATTR_READERS)

    def self.extended(base)
      # Load modules
      base.extend Assertions
      base.send :include, Callbacks
      base.send :include, Matches
      base.send :include, Optionals

      # Set the default value for matcher_arguments
      base.instance_variable_set('@matcher_arguments', { :names => [] })
    end

    # Make Remarkable::Base DSL inheritable.
    #
    def inherited(base)
      base.class_eval do
        class << self
          attr_reader *ATTR_READERS
        end
      end

      ATTR_READERS.each do |attr|
        current_value = self.instance_variable_get("@#{attr}")
        base.instance_variable_set("@#{attr}", current_value ? current_value.dup : [])
      end
    end
  end
end
