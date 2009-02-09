module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class HaveClassMethods < Remarkable::Matcher::Base
        def initialize(*methods)
          methods.extract_options!
          @methods = methods
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@methods) do |method|
            @method = method
            have_class_method?
          end
        end

        def description
          "respond to class method #{@methods.to_sentence}"
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        private

        def have_class_method?
          return true if subject_class.respond_to?(@method)

          @missing = "#{subject_name} does not have class method #{@method}"
          return false
        end

        def expectation
          "#{subject_name} to respond to class method #{@method}"
        end
      end

      # Ensure that the given class methods are defined on the model.
      #
      #   it { should have_class_methods(:find, :destroy) }
      #
      def have_class_methods(*methods)
        HaveClassMethods.new(*methods)
      end
    end
  end
end
