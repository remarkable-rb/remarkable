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

        def odd(value = true)
          @options[:odd] = value
          self
        end

        def even(value = true)
          @options[:even] = value
          self
        end

        def odd_message(value)
          @options[:odd_message] = value
          self
        end

        def even_message(value)
          @options[:even_message] = value
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            only_allow_numeric_values? && allow_blank? && allow_nil? &&
            only_integer? && allow_odd? && allow_even?
          end
        end

        def description
          default_message + "values for #{@attributes.to_sentence}"
        end

        private

        def only_allow_numeric_values?
          return true if bad?("abcd")

          @missing = "allow non-numeric values for #{@attribute}"
          false
        end

        # TODO Add support to <= and >= in only_integer
        def only_integer?
          return true unless @options.key? :only_integer

          if @options[:only_integer]
            return true if bad?(valid_value_for_test.to_f)
          else
            return true if good?(valid_value_for_test.to_f)
          end

          @missing = "#{'not ' unless @options[:only_integer]}allow non-integer values for #{@attribute}"
          false
        end

        # TODO Add support to <= and >= in even
        def allow_even?
          return true unless @options.key? :even

          if @options[:even]
            return true if bad?(1, :even_message)
          else
            return true if good?(1, :even_message)
          end

          @missing = "#{'not ' unless @options[:even]}allow even values for #{@attribute}"
          false
        end

        # TODO Add support to <= and >= in odd
        def allow_odd?
          return true unless @options.key? :odd

          if @options[:odd]
            return true if bad?(2, :odd_message)
          else
            return true if good?(2, :odd_message)
          end

          @missing = "#{'not ' unless @options[:odd]}allow odd values for #{@attribute}"
          false
        end

        # Returns a valid value for testing.
        #
        def valid_value_for_test
          if @options[:even]
            2
          elsif @options[:odd]
            1
          else
            10
          end
        end

        def load_options(options = {})
          @options = {
            :message => :not_a_number,
            :odd_message => :odd,
            :even_message => :even
          }.merge(options)
        end

        def expectation
          default_message + "values for #{@attribute}"
        end

        def default_message
          message = "to only allow "
          message << "even " if @options[:even]
          message << "odd " if @options[:even]
          message << (@options[:only_integer] ? "integer " : "numeric ")
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
      # * <tt>:only_integer</tt> - when supplied, checks if it accepts only integers or not
      # * <tt>:odd</tt> - when supplied, checks if it accepts only odd values or not
      # * <tt>:even</tt> - when supplied, checks if it accepts only even values or not
      # * <tt>:odd_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.odd')</tt>
      # * <tt>:even_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.even')</tt>
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.not_a_number')</tt>
      #
      # Example:
      #
      #   it { should validates_numericality_of(:age, :price) }
      #   it { should validates_numericality_of(:age, :only_integer => true) }
      #   it { should validates_numericality_of(:price, :only_integer => false) }
      #   it { should validates_numericality_of(:age).only_integer }
      #
      #   it { should validates_numericality_of(:age).odd }
      #   it { should validates_numericality_of(:age).even }
      #   it { should validates_numericality_of(:age, :odd => true) }
      #   it { should validates_numericality_of(:age, :even => true) }
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
