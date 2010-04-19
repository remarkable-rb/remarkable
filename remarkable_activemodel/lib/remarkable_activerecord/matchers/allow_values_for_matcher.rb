module Remarkable
  module ActiveRecord
    module Matchers
      class AllowValuesForMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        include Remarkable::Negative
        arguments :collection => :attributes, :as => :attribute

        optional :message
        optional :in, :splat => true
        optional :allow_nil, :allow_blank, :default => true

        collection_assertions :is_valid?, :is_invalid?, :allow_nil?, :allow_blank?

        default_options :message => /.*/

        before_assert do
          first_value = @options[:in].is_a?(Array) ? @options[:in].first : @options[:in]
          @in_range = first_value.is_a?(Range)

          @options[:in] = if @in_range
            first_value.to_a[0,2] + first_value.to_a[-2,2]
          else
            [*@options[:in]].compact
          end

          @options[:in].uniq!
        end

        protected

          def is_valid?
            assert_collection :value, valid_values do |value|
              good?(value)
            end
          end

          def is_invalid?
            assert_collection :value, invalid_values do |value|
              bad?(value)
            end
          end

          def valid_values
            @options[:in]
          end

          def invalid_values
            []
          end

          def interpolation_options
            options = if @in_range
              { :in => (@options[:in].first..@options[:in].last).inspect }
            elsif @options[:in].is_a?(Array)
              { :in => array_to_sentence(@options[:in], true, '[]') }
            else
              { :in => @options[:in].inspect }
            end

            options.merge!(:behavior => @behavior.to_s)
          end

      end

      # Ensures that the attribute can be set to the given values. It checks
      # for any message in the given attribute unless a :message is explicitely
      # given.
      #
      # == Options
      #
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors[:attribute]</tt>.
      #   Regexp, string or symbol.  Default = <tt>/.*/</tt>
      #
      # == Examples
      #
      #   should_allow_values_for :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
      #   it { should allow_values_for(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
      #
      def allow_values_for(attribute, *args, &block)
        options = args.extract_options!
        AllowValuesForMatcher.new(attribute, options.merge!(:in => args), &block).spec(self)
      end

    end
  end
end
