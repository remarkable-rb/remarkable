module Remarkable # :nodoc:
  module Matcher # :nodoc:
    class Base
      include Remarkable::Matcher::DSL

      def negative
        @negative = true
        self
      end

      def failure_message
        "Expected #{expectation} (#{@missing})"
      end

      def negative_failure_message
        "Did not expect #{expectation}"
      end

      def spec(spec)
        @spec = spec
        self
      end

      private

      def subject_class
        @subject.is_a?(Class) ? @subject : @subject.class
      end

      def subject_name
        subject_class.name
      end

      def positive?
        @negative ? false : true
      end

      def negative?
        @negative ? true : false
      end

      def assert_matcher(&block)
        if positive?
          return false unless yield
        else
          return true if yield
        end
        positive?
      end

      def assert_matcher_for(collection, &block)
        collection.each do |item|
          if positive?
            return false unless yield(item)
          else
            return true if yield(item)
          end
        end
        positive?
      end

    end
  end
end
