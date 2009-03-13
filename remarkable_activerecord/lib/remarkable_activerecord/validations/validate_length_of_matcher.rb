module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateLengthOfMatcher < Remarkable::ActiveRecord::Base
        arguments :collection => :attributes, :as => :attribute

        optional :within, :alias => :in
        optional :minimum, :maximum, :is
        optional :allow_nil, :allow_blank, :default => true
        optional :message, :too_short, :too_long, :wrong_length

        collection_assertions :less_than_min_length?, :exactly_min_length?,
                              :more_than_max_length?, :exactly_max_length?,
                              :allow_nil?, :allow_blank?

        before_assert do
          # Reassign :in to :within
          @options[:within] ||= @options.delete(:in) if @options.key?(:in)

          if @options[:is]
            @min_value, @max_value = @options[:is], @options[:is]
          elsif @options[:within]
            @min_value, @max_value = @options[:within].first, @options[:within].last
          elsif @options[:maximum]
            @min_value, @max_value = nil, @options[:maximum]
          elsif @options[:minimum]
            @min_value, @max_value = @options[:minimum], nil
          end
        end

        default_options :too_short => :too_short, :too_long => :too_long, :wrong_length => :wrong_length

        protected
          def allow_nil?
            super(default_message_for(:too_short))
          end

          def allow_blank?
            super(default_message_for(:too_short))
          end

          def less_than_min_length?
            return true if @min_value.nil? || @min_value <= 1 ||
                           bad?(value_for_length(@min_value - 1), default_message_for(:too_short))

            return false, :count => @min_value
          end

          def exactly_min_length?
            return true if @min_value.nil? || @min_value <= 0 ||
                           good?(value_for_length(@min_value), default_message_for(:too_short))

            return false, :count => @min_value
          end

          def more_than_max_length?
            return true if @max_value.nil? ||
                           bad?(value_for_length(@max_value + 1), default_message_for(:too_long))

            return false, :count => @max_value
          end

          def exactly_max_length?
            return true if @max_value.nil? || @min_value == @max_value ||
                           good?(value_for_length(@max_value), default_message_for(:too_long))

            return false, :count => @max_value
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
            @options.key?(:is) ? :wrong_length : validation_type
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
      # == Options
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
      # == Examples
      #
      #   should_validate_length_of :password, :within => 6..20
      #   should_validate_length_of :password, :maximum => 20
      #   should_validate_length_of :password, :minimum => 6
      #   should_validate_length_of :age, :is => 18
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
