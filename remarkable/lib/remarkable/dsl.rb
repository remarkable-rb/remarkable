dir = File.dirname(__FILE__)
require File.join(dir, 'dsl', 'assertions')
require File.join(dir, 'dsl', 'optionals')
require File.join(dir, 'dsl', 'matches')
require File.join(dir, 'dsl', 'description')

module Remarkable
  module DSL
    def self.extended(base)
      base.extend Assertions
      base.extend Optionals
      base.send :include, Matches
      base.send :include, Description
    end

    # Make Remarkable::Base DSL inheritable.
    #
    def inherited(base)
      base.class_eval do
        class << self
          attr_reader :matcher_arguments, :matcher_optionals, :matcher_assertions, :matcher_for_assertions
        end
      end

      base.instance_variable_set('@matcher_arguments',      @matcher_arguments      || { :names => [] })
      base.instance_variable_set('@matcher_optionals',      @matcher_optionals      || [])
      base.instance_variable_set('@matcher_assertions',     @matcher_assertions     || [])
      base.instance_variable_set('@matcher_for_assertions', @matcher_for_assertions || [])
    end
  end
end
