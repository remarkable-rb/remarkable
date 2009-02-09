module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateLengthOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(attributes, range, behavior, options = {})
          @attributes = attributes
          @behavior   = behavior

          # Set the values, for example:
          #
          #   send(:within, 0..10)
          #
          send(@behavior, range)

          load_options(options)
        end

        # If message is supplied, reassign it properly to :short_message
        # and :long_message. This is ActiveRecord default behavior when
        # the validation is :maximum, :minimum or :is.
        #
        def message(message)
          if [:is, :minimum, :maximum].include? @behavior
            short_message(message)
            long_message(message)
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
          @options[:message] = message # make a copy in @options[:message], for
                                       # allow_blank and allow_nil work properly.
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

            less_than_min_length? && exactly_min_length? && allow_nil?(:message, @minimum) &&
            more_than_max_length? && exactly_max_length? && allow_blank?(:message, @minimum)
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
          return true if bad?(value_for_length(@minimum - 1), :short_message, @minimum)

          @missing = "allow #{@attribute} to be less than #{@minimum} chars long"
          return false
        end

        def exactly_min_length?
          return true if @behavior == :maximum || @minimum <= 0
          return true if good?(value_for_length(@minimum), :short_message, @minimum)

          @missing = "not allow #{@attribute} to be exactly #{@minimum} chars long"
          return false
        end

        def more_than_max_length?
          return true if @behavior == :minimum
          return true if bad?(value_for_length(@maximum + 1), :long_message, @maximum)

          @missing = "allow #{@attribute} to be more than #{@maximum} chars long"
          return false
        end

        def exactly_max_length?
          return true if @behavior == :minimum || @minimum == @maximum
          return true if good?(value_for_length(@maximum), :long_message, @maximum)

          @missing = "not allow #{@attribute} to be exactly #{@maximum} chars long"
          return false
        end

        def load_options(options)
          if @behavior == :is
            @options = {
              :short_message => :wrong_length,
              :long_message => :wrong_length
            }.merge(options)
          else
            @options = {
              :short_message => :too_short,
              :long_message => :too_long
            }.merge(options)
          end

          # Reassign messages properly
          message(@options[:message]) if @options[:message]
          long_message(@options[:long_message])
          short_message(@options[:short_message])
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

          message << " or nil"   if @options[:allow_nil]
          message << " or blank" if @options[:allow_blank]
          message
        end

        def value_for_length(value)
          "x" * value
        end
      end

      # Validates the length of the given attributes. You have also to supply
      # one of the following options: minimum, maximum, is or within.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Note: this method is also aliased as <tt>validate_length_of</tt>.
      #
      # Options:
      #
      # * <tt>:minimum</tt> - The minimum size of the attribute.
      # * <tt>:maximum</tt> - The maximum size of the attribute.
      # * <tt>:is</tt> - The exact size of the attribute.
      # * <tt>:within</tt> - A range specifying the minimum and maximum size of the attribute.
      # * <tt>:in</tt> - A synonym(or alias) for :within.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
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
      #   it { should validates_length_of(:password, :maximum => 20) }
      #   it { should validates_length_of(:password, :minimum => 6) }
      #   it { should validates_length_of(:age, :is => 18) }
      #
      #   it { should validates_length_of(:password).within(6..20) }
      #   it { should validates_length_of(:password).maximum(20) }
      #   it { should validates_length_of(:password).minimum(6) }
      #   it { should validates_length_of(:age).is(18) }
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
      alias :ensure_length_of :validate_length_of

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
