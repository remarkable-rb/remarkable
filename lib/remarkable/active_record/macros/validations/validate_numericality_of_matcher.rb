module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateNumericalityOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute
            only_allow_numeric_values? && allow_blank? && allow_nil?
          end
        end

        def description
          message = "to only allow numeric "
          message << "or nil "   if @options[:allow_nil]
          message << "or blank " if @options[:allow_blank]
          message << "values for #{@attributes.to_sentence}"
          message
        end

        private

        def only_allow_numeric_values?
          return true if assert_bad_value(@subject, @attribute.to_sym, "abcd", @options[:message])

          @missing = "allow non-numeric values for #{@attribute}"
          false
        end

        def load_options(options = {})
          @options = {
            :message => :not_a_number
          }.merge(options)
        end

        def expectation
          message = "to only allow numeric "
          message << "or nil "   if @options[:allow_nil]
          message << "or blank " if @options[:allow_blank]
          message << "values for #{@attribute}"
          message
        end
      end

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
