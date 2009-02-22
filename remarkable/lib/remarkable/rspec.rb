# Hacks into rspec to provide I18n.
#
module Spec #:nodoc:
  module Matchers #:nodoc:
    # Provides I18n on should and should_not.
    #
    def self.generated_description
      return nil if last_should.nil?
      verb = Remarkable.t "remarkable.core.#{last_should}", :default => last_should.to_s.gsub('_',' ')
      "#{verb} #{last_description}"
    end
  end

  module Example #:nodoc:
    module ExampleGroupMethods #:nodoc:
      # Provides I18n on example disabled message.
      #
      def xexample(description=nil, opts={}, &block)
        disabled = Remarkable.t 'remarkable.core.example_disabled', :default => 'Example disabled'
        Kernel.warn("#{disabled}: #{description}")
      end
      alias_method :xit, :xexample
      alias_method :xspecify, :xexample
    end
  end
end

# Hacks into rspec to extend should and should_not (when called without subjects).
#
module Remarkable
  module ExampleMethods #:nodoc:

    # We extend should and should_not methods by doing two things. The first
    # is sending the spec binding to a matcher if it's a Remarkable matcher.
    # After we try to find a subject for it from the registered subjects. If
    # we can't, we will call super.
    #
    def should_with_remarkable_hooks(method, matcher)
      matcher.spec(self) if matcher.class.ancestors.include?(Remarkable::Base)

      Remarkable.registered_subjects.each do |condition, block|
        return instance_eval(&block).send(method, matcher) if condition.call(matcher)
      end

      nil
    end

    def should(matcher=nil) #:nodoc:
      super(matcher) unless should_with_remarkable_hooks(:should, matcher)
    end

    def should_not(matcher) #:nodoc:
      super(matcher) unless should_with_remarkable_hooks(:should_not, matcher)
    end

  end
end

Spec::Example::ExampleMethods.send :include, Remarkable::ExampleMethods
