module Remarkable # :nodoc:
  module Default # :nodoc:
    module Helpers # :nodoc:
      # Asserts that the given collection contains item x.  If x is a regular expression, ensure that
      # at least one element from the collection matches x.  +extra_msg+ is appended to the error message if the assertion fails.
      #
      #   assert_contains(['a', '1'], /\d/) => passes
      #   assert_contains(['a', '1'], 'a') => passes
      #   assert_contains(['a', '1'], /not there/) => fails
      def assert_contains(collection, x) # :nodoc:
        collection = [collection] unless collection.is_a?(Array)

        case x
        when Regexp
          collection.detect { |e| e =~ x }
        else         
          collection.include?(x)
        end
      end

      # Asserts that the given collection does not contain item x.  If x is a regular expression, ensure that
      # none of the elements from the collection match x.
      def assert_does_not_contain(collection, x) # :nodoc:
        !assert_contains(collection, x)
      end
    end
  end
end
