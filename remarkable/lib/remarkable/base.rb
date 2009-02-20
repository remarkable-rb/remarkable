module Remarkable
  class Base
    include Remarkable::Messages
    extend  Remarkable::DSL

    private

      # Returns the subject class if it's not one.
      def subject_class
        nil unless @subject
        @subject.is_a?(Class) ? @subject : @subject.class
      end

      # Returns the subject name based on its class. If the class respond to
      # human_name (which is usually localized) returns it.
      def subject_name
        nil unless @subject
        subject_class.respond_to?(:human_name) ? subject_class.human_name : subject_class.name
      end

      # Assert the block given.
      def assert_matcher
        return false unless yield
        true
      end

      # Same as <tt>assert_matcher</tt> but actually iterates over the
      # collection given.
      def assert_matcher_for(collection)
        collection.each do |item|
          return false unless yield(item)
        end
        true
      end

      # Asserts that the given collection contains item x. If x is a regular
      # expression, ensure that at least one element from the collection matches x.
      #
      #   assert_contains(['a', '1'], /\d/) => passes
      #   assert_contains(['a', '1'], 'a') => passes
      #   assert_contains(['a', '1'], /not there/) => fails
      #
      def assert_contains(collection, x) # :nodoc:
        collection = [collection] unless collection.is_a?(Array)

        case x
        when Regexp
          collection.detect { |e| e =~ x }
        else
          collection.include?(x)
        end
      end

  end
end
