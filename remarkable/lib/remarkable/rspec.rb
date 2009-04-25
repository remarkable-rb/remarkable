module Spec #:nodoc:
  module Matchers #:nodoc:
    # Overwrites to provide I18n on should and should_not.
    #
    def self.generated_description
      return nil if last_should.nil?
      verb = Remarkable.t "remarkable.core.#{last_should}", :default => last_should.to_s.gsub('_',' ')
      "#{verb} #{last_description}"
    end
  end

  module Example #:nodoc:
    module ExampleGroupMethods #:nodoc:
      # Overwrites to provide I18n on example disabled message.
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
