module Remarkable
  class Base
    include Remarkable::Messages
    include Remarkable::DSL

    # This method is called in <tt>should_not</tt> cases to mark the current
    # matcher as negative.
    def negative
      @negative = true
      self
    end

    # Receives the spec instance. Needed in all matchers.
    def spec(spec)
      @spec = spec
      self
    end

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

      def positive? #:nodoc:
        @negative ? false : true
      end

      def negative? #:nodoc:
        @negative ? true : false
      end

      # Assert the block given considering if the matcher is positive or
      # negative.
      def assert_matcher(&block)
        if positive?
          return false unless yield
        else
          return true if yield
        end
        positive?
      end

      # Same as <tt>assert_matcher</tt> but actually iterates over the
      # collection given.
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
