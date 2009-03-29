module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateLengthOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        arguments :behavior, :range, :attributes
        optional  :message, :minimum, :maximum, :too_short, :too_long, :wrong_length

        assertions :less_than_min_length?, :exactly_min_length?, :allow_nil?,
                   :more_than_max_length?, :exactly_max_length?, :allow_blank?

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
          { :too_long => :too_long, :too_short => :too_short, :wrong_length => :wrong_length }
        end

        def before_assert
          # Set the values, for example:
          # send(:within, 0..10)
          send(@behavior, @range)
        end

        def allow_nil?
          super(default_message_for(:too_short))
        end

        def allow_blank?
          super(default_message_for(:too_short))
        end

        def less_than_min_length?
          return true if @behavior == :maximum || @options[:minimum] <= 1
          return true if bad?(value_for_length(@options[:minimum] - 1), default_message_for(:too_short))

          @missing = "allow #{@attribute} to be less than #{@options[:minimum]} chars long"
          return false
        end

        def exactly_min_length?
          return true if @behavior == :maximum || @options[:minimum] <= 0
          return true if good?(value_for_length(@options[:minimum]), default_message_for(:too_short))

          @missing = "not allow #{@attribute} to be exactly #{@options[:minimum]} chars long"
          return false
        end

        def more_than_max_length?
          return true if @behavior == :minimum
          return true if bad?(value_for_length(@options[:maximum] + 1), default_message_for(:too_long))

          @missing = "allow #{@attribute} to be more than #{@options[:maximum]} chars long"
          return false
        end

        def exactly_max_length?
          return true if @behavior == :minimum || @options[:minimum] == @options[:maximum]
          return true if good?(value_for_length(@options[:maximum]), default_message_for(:too_long))

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

        # Returns the default message for the validation type.
        # If user supplied :message, it will return it. Otherwise it will return
        # wrong_length on :is validation and :too_short or :too_long in the other
        # types.
        #
        def default_message_for(validation_type)
          return :message if @options[:message]
          @behavior == :is ? :wrong_length : validation_type
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
      # * <tt>:too_short</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt> when attribute is too short.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.too_short') % range.first</tt>
      # * <tt>:too_long</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt> when attribute is too long.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.too_long') % range.last</tt>
      # * <tt>:wrong_length</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt> when attribute is the wrong length.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.wrong_length') % range.last</tt>
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>. When supplied overwrites :too_short, :too_long and :wrong_length.
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
    end
  end
end
