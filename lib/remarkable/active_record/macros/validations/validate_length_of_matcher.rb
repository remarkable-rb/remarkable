module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateLengthOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        arguments :behavior, :range, :attributes
        optional  :minimum, :maximum, :short_message, :long_message

        assertions :less_than_min_length?, :exactly_min_length?, :allow_nil?,
                   :more_than_max_length?, :exactly_max_length?, :allow_blank?

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
          @options[:minimum] = range.first
          @options[:maximum] = range.last
          self
        end
        alias :in :within

        def is(value)
          @options[:minimum] = value
          @options[:maximum] = value
          self
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

        def default_options
          if @behavior == :is
            { :short_message => :wrong_length, :long_message => :wrong_length }
          else
            { :short_message => :too_short, :long_message => :too_long }
          end
        end

        # Reassign messages properly
        def after_initialize
          # Set the values, for example:
          # send(:within, 0..10)
          send(@behavior, @range)

          message(@options.delete(:message)) if @options[:message]
          long_message(@options[:long_message])
          short_message(@options[:short_message])
        end

        def allow_nil?
          super(:short_message)
        end

        def allow_blank?
          super(:short_message)
        end

        def less_than_min_length?
          return true if @behavior == :maximum || @options[:minimum] <= 0
          return true if bad?(value_for_length(@options[:minimum] - 1), :short_message)

          @missing = "allow #{@attribute} to be less than #{@options[:minimum]} chars long"
          return false
        end

        def exactly_min_length?
          return true if @behavior == :maximum || @options[:minimum] <= 0
          return true if good?(value_for_length(@options[:minimum]), :short_message)

          @missing = "not allow #{@attribute} to be exactly #{@options[:minimum]} chars long"
          return false
        end

        def more_than_max_length?
          return true if @behavior == :minimum
          return true if bad?(value_for_length(@options[:maximum] + 1), :long_message)

          @missing = "allow #{@attribute} to be more than #{@options[:maximum]} chars long"
          return false
        end

        def exactly_max_length?
          return true if @behavior == :minimum || @options[:minimum] == @options[:maximum]
          return true if good?(value_for_length(@options[:maximum]), :long_message)

          @missing = "not allow #{@attribute} to be exactly #{@options[:maximum]} chars long"
          return false
        end

        def expectation
          message = "that the length of the #{@attribute} is "

          message << if @behavior == :within
            "between #{@options[:minimum]} and #{@options[:maximum]}"
          elsif @behavior == :minimum
            "more than #{@options[:minimum]}"
          elsif @behavior == :maximum
            "less than #{@options[:maximum]}"
          else #:is
            "equal to #{@options[:minimum]}"
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
      # Note: this method is also aliased as <tt>validate_size_of</tt>.
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
      #   it { should validate_length_of(:password, :within => 6..20) }
      #   it { should validate_length_of(:password, :maximum => 20) }
      #   it { should validate_length_of(:password, :minimum => 6) }
      #   it { should validate_length_of(:age, :is => 18) }
      #
      #   it { should validate_length_of(:password).within(6..20) }
      #   it { should validate_length_of(:password).maximum(20) }
      #   it { should validate_length_of(:password).minimum(6) }
      #   it { should validate_length_of(:age).is(18) }
      #
      def validate_length_of(*attributes)
        matcher = nil
        options = attributes.extract_options!

        [:within, :in, :maximum, :minimum, :is].each do |behavior|
          if options.key? behavior
            matcher ||= ValidateLengthOfMatcher.new(behavior, options.delete(behavior), *(attributes << options))
          end
        end

        raise ArgumentError, 'You have to give one of these options: :within, :is, :maximum or :minimum.' if matcher.nil?
        matcher
      end
      alias :validate_size_of :validate_length_of

      # TODO This one is for shoulda compatibility. Deprecate it?
      def ensure_length_of(*attributes) #:nodoc:
        warn "[DEPRECATION] should_ensure_length_of is deprecated. " <<
             "Use should_validate_length_of instead."
        validate_length_of(*attributes)
      end

      # TODO Deprecate me
      def ensure_length_in_range(attribute, range, options = {}) #:nodoc:
        warn "[DEPRECATION] should_ensure_length_in_range is deprecated. " <<
             "Use should_validate_length_of(#{attribute.inspect}, :in => #{range.inspect}) instead."
        ValidateLengthOfMatcher.new(:within, range, attribute, options)
      end

      # TODO Deprecate me
      def ensure_length_at_least(attribute, range, options = {}) #:nodoc:
        warn "[DEPRECATION] should_ensure_length_at_least is deprecated. " <<
             "Use should_validate_length_of(#{attribute.inspect}, :minimum => #{range.inspect}) instead."
        ValidateLengthOfMatcher.new(:minimum, range, attribute, options)
      end

      # TODO Deprecate me
      def ensure_length_is(attribute, range, options = {}) #:nodoc:
        warn "[DEPRECATION] should_ensure_length_is is deprecated. " <<
             "Use should_validate_length_of(#{attribute.inspect}, :is => #{range.inspect}) instead."
        ValidateLengthOfMatcher.new(:is, range, attribute, options)
      end
    end
  end
end
