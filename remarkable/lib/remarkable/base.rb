module Remarkable
  class Base
    include Remarkable::Messages
    extend  Remarkable::DSL

    # Optional to provide spec binding to matchers.
    def spec(binding)
      @spec = binding
      self
    end

    protected

      # Returns the subject class unless it's a class object.
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

      # Iterates over the collection given yielding the block and return false
      # if any of them also returns false.
      def assert_matcher_for(collection) #:nodoc:
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
      def assert_contains(collection, x)
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
