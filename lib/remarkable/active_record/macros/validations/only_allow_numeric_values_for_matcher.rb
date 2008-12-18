module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class OnlyAllowNumericValuesFor < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers
        
        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def message(message)
          @options[:message] = message
          self
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            only_allow_numeric_values?
          end
        end

        def description
          "only allow numeric values for #{@attributes.to_sentence}"
        end
        
        private
        
        def only_allow_numeric_values?
          attribute = @attribute.to_sym
          return true if assert_bad_value(@subject, attribute, "abcd", @options[:message])
          
          @missing = "allow non-numeric values for #{attribute}"
          return false
        end
        
        def load_options(options)
          @options = {
            :message => default_error_message(:not_a_number)
          }.merge(options)
        end
        
        def expectation
          "only allow numeric values for #{@attribute}"
        end
      end

      # Ensure that the attribute is numeric
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #   it { should only_allow_numeric_values_for(:age) }
      #
      def only_allow_numeric_values_for(*attributes)
        OnlyAllowNumericValuesFor.new(*attributes)
      end
    end
  end
end
