module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateLengthOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attributes, range, behavior, options)
          @attributes = attributes
          @behavior   = behavior

          # Set the values, for example:
          #
          #   send(:within, 0..10)
          #
          send(@behavior, range)

          load_options(options)
        end

        # This is used only when :is, :minimum or :maximum like in ActiveRecord.
        #
        def message(message)
          if [:is, :minimum, :maximum].include? @behavior
            @options[:short_message] = message
            @options[:long_message] = message
          end
          self
        end

        def within(range)
          @behavior = :within
          @minimum  = range.first
          @maximum  = range.last
          self
        end
        alias :in :within

        def minimum(value)
          @minimum = value
          self
        end

        def maximum(value)
          @maximum = value
          self
        end

        def is(value)
          @minimum = value
          @maximum = value
          self
        end

        def short_message(message)
          @options[:short_message] = message
          self
        end

        def long_message(message)
          @options[:long_message] = message
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute

            less_than_min_length? && exactly_min_length? &&
            more_than_max_length? && exactly_max_length?
          end
        end

        def description
          "ensure #{expectation}"
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        private

        def less_than_min_length?
          return true if @behavior == :maximum || @minimum <= 0

          min_value = "x" * (@minimum - 1)
          return true if assert_bad_value(@subject, @attribute, min_value, @options[:short_message])

          @missing = "allow #{@attribute} to be less than #{@minimum} chars long"
          return false
        end

        def exactly_min_length?
          return true if @behavior == :maximum || @minimum <= 0

          min_value = "x" * @minimum
          return true if assert_good_value(@subject, @attribute, min_value, @options[:short_message])

          @missing = "not allow #{@attribute} to be exactly #{@minimum} chars long"
          return false
        end

        def more_than_max_length?
          return true if @behavior == :minimum

          max_value = "x" * (@maximum + 1)
          return true if assert_bad_value(@subject, @attribute, max_value, @options[:long_message])

          @missing = "allow #{@attribute} to be more than #{@maximum} chars long"
          return false
        end

        def exactly_max_length?
          return true if @behavior == :minimum || @minimum == @maximum

          max_value = "x" * @maximum
          return true if assert_good_value(@subject, @attribute, max_value, @options[:long_message])

          @missing = "not allow #{@attribute} to be exactly #{@maximum} chars long"
          return false
        end

        def load_options(options)
          if @behavior == :is
            @options = {
              :short_message => { :wrong_length => { :count => @minimum } },
              :long_message => { :wrong_length => { :count => @maximum } }
            }.merge(options)
          else
            @options = {
              :short_message => { :too_short => { :count => @minimum } },
              :long_message => { :too_long => { :count => @maximum } }
            }.merge(options)
          end

          # If message is supplied, reassign it properly to :short_message
          # and :long_message. This is ActiveRecord default behavior when
          # the validation is :maximum, :minimum or :is.
          #
          message(@options[:message]) if @options[:message]
        end

        def expectation
          message = "that the length of the #{@attribute} is "

          message << if @behavior == :within
            "between #{@minimum} and #{@maximum}"
          elsif @behavior == :minimum
            "more than #{@minimum}"
          elsif @behavior == :maximum
            "less than #{@maximum}"
          else #:is
            "equal to #{@minimum}"
          end
        end
      end

      # Validates the length of the attribute.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      #
      # * <tt>:minimum - The minimum size of the attribute.
      # * <tt>:maximum - The maximum size of the attribute.
      # * <tt>:is - The exact size of the attribute.
      # * <tt>:within - A range specifying the minimum and maximum size of the attribute.
      # * <tt>:in - A synonym(or alias) for :within.
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
      # * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt> only when :minimum, :maximum or :is is given.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.wrong_length') % value</tt>
      #
      # Example:
      #
      #   it { should validates_length_of(:password, :within => 6..20) }
      #   it { should validates_length_of(:password, :in => 6..20) }
      #   it { should validates_length_of(:password, :maximum => 20) }
      #   it { should validates_length_of(:password, :minimum => 6) }
      #   it { should validates_length_of(:age, :is => 18) }
      #
      def validate_length_of(*attributes)
        matcher = nil
        options = attributes.extract_options!

        [:within, :in, :maximum, :minimum, :is].each do |behavior|
          if options.key? behavior
            matcher ||= ValidateLengthOfMatcher.new(attributes, options.delete(behavior), behavior, options)
          end
        end

        raise ArgumentError, 'You have to give one of these options: :within, :is, :maximum or :minimum.' if matcher.nil?
        matcher
      end
      alias :validate_size_of :validate_length_of

      # Ensures that the length of the attribute is in the given range
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      # * <tt>:short_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
      # * <tt>:long_message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
      #
      # Example:
      #
      #   it { should ensure_length_in_range(:password, 6..20) }
      #
      # TODO Deprecate me
      def ensure_length_in_range(attribute, range, options = {})
        ValidateLengthOfMatcher.new([attribute], range, :within, options)
      end

      # TODO Deprecate me
      def ensure_length_at_least(attribute, range, options = {})
        ValidateLengthOfMatcher.new([attribute], range, :minimum, options)
      end

      # TODO Deprecate me
      def ensure_length_no_more(attribute, range, options = {})
        ValidateLengthOfMatcher.new([attribute], range, :maximum, options)
      end

      # TODO Deprecate me
      def ensure_length_is(attribute, range, options = {})
        ValidateLengthOfMatcher.new([attribute], range, :is, options)
      end
    end
  end
end
