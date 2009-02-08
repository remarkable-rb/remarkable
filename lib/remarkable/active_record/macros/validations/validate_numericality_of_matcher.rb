module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateNumericalityOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def only_integer(value = true)
          @options[:only_integer] = value
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            only_allow_numeric_values? && allow_blank? && allow_nil? &&
            only_integer?
          end
        end

        def description
          default_message + "values for #{@attributes.to_sentence}"
        end

        private

        def only_allow_numeric_values?
          return true if assert_bad_value(@subject, @attribute, "abcd", @options[:message])

          @missing = "allow non-numeric values for #{@attribute}"
          false
        end

        # TODO Add support to <= and >= in only_integer
        def only_integer?
          return true unless @options.key? :only_integer

          if @options[:only_integer]
            return true if assert_bad_value(@subject, @attribute, 1.0, @options[:message])
          else
            return true if assert_good_value(@subject, @attribute, 1.0, @options[:message])
          end

          @missing = "#{'not ' unless @options[:only_integer]}allow non-integer values for #{@attribute}"
          false
        end

        def load_options(options = {})
          @options = {
            :message => :not_a_number
          }.merge(options)
        end

        def expectation
          default_message + "values for #{@attribute}"
        end

        def default_message
          message = @options[:only_integer] ? "to only allow integer " : "to only allow numeric "
          message << "or nil "   if @options[:allow_nil]
          message << "or blank " if @options[:allow_blank]
          message
        end
      end

      # Ensures that the given attributes accepts only numbers.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that. Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      #
      # * <tt>:only_integer</tt> - Is true if the given attributes accepts only integers
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #
      #   it { should validates_numericality_of(:age, :price) }
      #   it { should validates_numericality_of(:age).only_integer }
      #
      def validate_numericality_of(*attributes)
        ValidateNumericalityOfMatcher.new(*attributes)
      end
      alias :only_allow_numeric_values_for :validate_numericality_of

      # TODO Deprecate this method and say that it has to be changed to:
      #
      #   validate_numericality_of :attribute, :allow_blank => true
      #
      def only_allow_numeric_or_blank_values_for(*attributes)
        ValidateNumericalityOfMatcher.new(*attributes).allow_blank
      end
    end
  end
end
