module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class HaveInstanceMethods < Remarkable::Matcher::Base
        def initialize(*methods)
          methods.extract_options!
          @methods = methods
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@methods) do |method|
            @method = method
            have_instance_method?
          end
        end

        def description
          "respond to instance method #{@methods.to_sentence}"
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        private
        
        def have_instance_method?
          return true if subject_class.new.respond_to?(@method)
          
          @missing = "#{subject_name} does not have instance method #{@method}"
          return false
        end

        def expectation
          "#{subject_name} to respond to instance method #{@method}"
        end
      end

      # Ensure that the given instance methods are defined on the model.
      #
      #   it { should have_instance_methods(:email, :name, :name=) }
      #
      def have_instance_methods(*methods)
        HaveInstanceMethods.new(*methods)
      end
    end
  end
end
