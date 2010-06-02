module RSpec #:nodoc:
  module Matchers #:nodoc:
    # Overwrites to provide I18n on should and should_not.
    #
    def self.generated_description
      return nil if last_should.nil?
      verb = Remarkable.t "remarkable.core.#{last_should}", :default => last_should.to_s.gsub('_',' ')
      "#{verb} #{last_description}"
    end
  end

  module Core #:nodoc:
    class ExampleGroup #:nodoc:
      # Overwrites to provide I18n on example disabled message.
      #
      def _xexample(description=nil, opts={}, &block)
        disabled = Remarkable.t 'remarkable.core.example_disabled', :default => 'Example disabled'
        Kernel.warn("#{disabled}: #{description}")
      end
      #alias_method :xit, :xexample
      #alias_method :xspecify, :xexample
      
      # NOTE: Hack. Disabled examples is not the same as pending examples
      # However, the rspec runner is monolithic and doesn't have a hook to process
      # examples based on metadata
      alias_example_to :xexample, :disabled => true, :pending => true
      alias_example_to :xit, :disabled => true, :pending => true
      alias_example_to :xspecify, :disabled => true, :pending => true
    end
  end
end
