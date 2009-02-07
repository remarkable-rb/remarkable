module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateInclusionOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attribute, behavior, *good_values)
          @attribute = attribute
          @behavior = behavior
          load_options(good_values.extract_options!)
          @good_values = good_values
        end

        def allow_nil(value = true)
          @options[:allow_nil] = value
          self
        end

        def message(message)
          @options[:message] = message
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@good_values) do |good_value|
            @good_value = good_value
            value_valid?
          end &&
          assert_matcher do
            allow_nil?
          end
        end

        def description
          @good_values << 'nil' if @options[:allow_nil]
          "#{verb} #{@behavior} of #{@good_values.to_sentence} #{preposition} #{@attribute}"
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end

        private

        def load_options(options)
          @options = {
            :message => @behavior
          }.merge(options)
        end

        def allow_nil?
          return true unless @options.key? :allow_nil

          @good_value = 'nil'
          if @options[:allow_nil]
            return true if assert_good_value(@subject, @attribute, nil, @options[:message])
          else
            return true if assert_bad_value(@subject, @attribute, nil, @options[:message])
          end

          @missing = "#{@attribute} can#{ 'not' if @options[:allow_nil] } be set to nil"
          false
        end

        def value_valid?
          if @behavior == :inclusion
            return true if assert_good_value(@subject, @attribute, @good_value, @options[:message])
          else
            return true if assert_bad_value(@subject, @attribute, @good_value, @options[:message])
          end

          @missing = "#{@good_value} cannot be #{sentence} #{@attribute}"
          false
        end

        def expectation
          "#{verb} #{@behavior} of #{@good_value} #{preposition} #{@attribute}"
        end

        # Helpers to generate the message. If inclusion:
        #
        #   Expected to allow inclusion of "ISBN 1-2345-6789-0" in isbn  ("ISBN 1-2345-6789-0" was not included in isbn)
        #
        # If exclusion:
        #
        #   Expected to ensure exclusion of "admin" from username ("admin" was not excluded from username)
        #
        def verb
          @behavior == :inclusion ? 'allow' : 'ensure'
        end

        def preposition
          @behavior == :inclusion ? 'in' : 'from'
        end

        def sentence
          @behavior == :inclusion ? 'included in' : 'excluded from'
        end
      end

      # Ensures that given values are valid for the attribute.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #   it { should validate_inclusion_of(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #   it { should_not validate_inclusion_of(:isbn, "bad 1", "bad 2") }
      #
      def validate_inclusion_of(attribute, *good_values)
        ValidateInclusionOfMatcher.new(attribute, :inclusion, *good_values)
      end
      alias :allow_inclusion_of :validate_inclusion_of

      # Ensures that given values are not valid for the attribute.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Example:
      #   it { should validate_exclusion_of(:username, "admin", "user") }
      #   it { should_not validate_exclusion_of(:username, "dhh", "peter_park") }
      #
      def validate_exclusion_of(attribute, *good_values)
        ValidateInclusionOfMatcher.new(attribute, :exclusion, *good_values)
      end
      alias :ensure_exclusion_of :validate_exclusion_of
    end
  end
end
