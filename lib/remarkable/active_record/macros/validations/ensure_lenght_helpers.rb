module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module EnsureLength
      module Helpers

        private

        def less_than_min_length?(attribute, min_length, short_message)
          return true unless min_length > 0

          min_value = "x" * (min_length - 1)
          return true if assert_bad_value(model_class, attribute, min_value, short_message)

          @missing = "allow #{attribute} to be less than #{min_length} chars long"
          return false          
        end

        def remove_parenthesis(text)
          /#{text.gsub(/\s?\(.*\)$/, '')}/
        end

      end
    end
  end
end
