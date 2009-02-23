module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateLengthOfMatcher < Remarkable::ActiveRecord::Base
        arguments :collection => :attributes

        optional :within, :alias => :in
        optional :minimum, :maximum, :is
        optional :allow_nil, :allow_blank, :default => true
        optional :message, :short_message, :long_message

        assertions :less_than_min_length?, :exactly_min_length?, :allow_nil?,
                   :more_than_max_length?, :exactly_max_length?, :allow_blank?

        # Reassign :in to :within
        after_initialize do
          @options[:within] ||= @options.delete(:in) if @options.key? :in
        end

        before_assert do
          super

          if @options[:is]
            @min_value, @max_value = @options[:is], nil
            @options[:message] ||= :wrong_length
          elsif @options[:within]
            @min_value, @max_value = @options[:within].first, @options[:within].last
          elsif @options[:maximum]
            @min_value, @max_value = nil, @options[:maximum]
          elsif @options[:minimum]
            @min_value, @max_value = @options[:minimum], nil
          end

          # Reassing message to short_message and long_message
          if @options[:message] && !@options.slice(:is, :maximum, :minimum).empty?
            @options[:short_message] = @options.delete(:message)
            @options[:long_message]  = @options[:short_message]
          end
        end

        default_options do
          { :short_message => :too_short, :long_message => :too_long }
        end

        protected
          def allow_nil?
            super(:short_message)
          end

          def allow_blank?
            super(:short_message)
          end

          def less_than_min_length?
            return true if @min_value.nil? || @min_value <= 1 ||
                           bad?(value_for_length(@min_value - 1), :short_message)

            return false, :count => @min_value
          end

          def exactly_min_length?
            return true if @min_value.nil? || @min_value <= 0 ||
                           good?(value_for_length(@min_value), :short_message)

            return false, :count => @min_value
          end

          def more_than_max_length?
            return true if @max_value.nil? ||
                           bad?(value_for_length(@max_value + 1), :long_message)

            return false, :count => @max_value
          end

          def exactly_max_length?
            return true if @max_value.nil? || @min_value == @max_value ||
                           good?(value_for_length(@max_value), :long_message)

            return false, :count => @max_value
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
        ValidateLengthOfMatcher.new(*attributes).spec(self)
      end
    end
  end
end
