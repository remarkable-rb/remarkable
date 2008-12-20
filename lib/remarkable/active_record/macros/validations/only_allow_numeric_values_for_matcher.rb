module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class OnlyAllowNumericValuesFor < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers
        
        def initialize(attributes, opts)
          @options = opts
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
          if allow_blank_values
            "only allow numeric or blank values for #{@attributes.to_sentence}"            
          else
            "only allow numeric values for #{@attributes.to_sentence}"
          end
        end
        
        private
        
        def only_allow_numeric_values?
          if allow_blank_values
            @missing = "allow non-numeric or blank values for #{@attribute.to_sym}"
            !is_bad_value("") && is_bad_value("abcd")
          else
            @missing = "allow non-numeric values for #{@attribute.to_sym}"            
            is_bad_value("") && is_bad_value("abcd")
          end
        end
        
        def load_options(options)
          key = :not_a_number
          @options.merge!({
            :message => default_error_message(key)
          }).merge!(options)
        end
        
        def expectation
          if allow_blank_values
            "only allow numeric or blank values for #{@attribute}"
          else
            "only allow numeric values for #{@attribute}"
          end
        end
        
        def is_bad_value(value)
          assert_bad_value(@subject, @attribute.to_sym, value, @options[:message])
        end
        
        def allow_blank_values
          @options[:allow_blank]
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
        OnlyAllowNumericValuesFor.new(attributes, :allow_blank => false)
      end
      
      def only_allow_numeric_or_blank_values_for(*attributes)
        OnlyAllowNumericValuesFor.new(attributes, :allow_blank => true)
      end
    end
  end
end
