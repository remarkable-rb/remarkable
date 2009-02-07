module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateNumericalityOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def message(message)
          @options[:message] = message
          self
        end

        def allow_blank(value = true)
          @options[:allow_blank] = value
          self
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute

            only_allow_numeric_values? && allow_blank?
          end
        end

        def description
          "to only allow numeric#{ ' or blank' if @options[:allow_blank] } values for #{@attributes.to_sentence}"
        end

        private

        def only_allow_numeric_values?
          return true if assert_bad_value(@subject, @attribute.to_sym, "abcd", @options[:message])

          @missing = "allow non-numeric values for #{@attribute}"
          false
        end

        def allow_blank?
          return true unless @options.key? :allow_blank

          if @options[:allow_blank]
            return true if assert_good_value(@subject, @attribute.to_sym, "", @options[:message])
          else
            return true if assert_bad_value(@subject, @attribute.to_sym, "", @options[:message])
          end

          @missing = "#{ 'not ' if @options[:allow_blank] }allow blank values for #{@attribute}"
          false
        end

        def load_options(options)
          @options = {
            :message => :not_a_number
          }.merge(options)
        end

        def expectation
          "to only allow numeric#{ ' or blank' if @options[:allow_blank] } values for #{@attribute}"
        end
      end

      def validate_numericality_of(*attributes)
        ValidateNumericalityOfMatcher.new(*attributes)
      end
      alias :only_allow_numeric_values_for :validate_numericality_of

      # We should put a deprecation warning on this one.
      # And said that it has to be changed to:
      #
      #   validate_numericality_of :attribute, :allow_blank => true
      #
      def only_allow_numeric_or_blank_values_for(*attributes)
        ValidateNumericalityOfMatcher.new(*attributes).allow_blank
      end
    end
  end
end
