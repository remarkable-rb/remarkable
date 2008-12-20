module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class NumericMatcher < Remarkable::Matcher::Base
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
          "only allow numeric#{ ' or blank' if @options[:allow_blank] } values for #{@attributes.to_sentence}"
        end
        
        private
        
        def only_allow_numeric_values?
          return true if assert_bad_value(@subject, @attribute.to_sym, "abcd", @options[:message])
          
          @missing = "allow non-numeric values for #{@attribute}"
          false
        end
        
        def allow_blank?
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
            :message => default_error_message(:not_a_number)
          }.merge(options)
        end
        
        def expectation
          "only allow numeric#{ ' or blank' if @options[:allow_blank] } values for #{@attribute}"
        end
      end
      
      def only_allow_numeric_values_for(*attributes)
        NumericMatcher.new(*attributes)
      end
      
      def only_allow_numeric_or_blank_values_for(*attributes)
        NumericMatcher.new(*attributes).allow_blank
      end
    end
  end
end
