module Remarkable # :nodoc:
  module Matcher # :nodoc:
    class Base
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

      def controller(controller)
        @controller = controller
        self
      end
      
      def response(response)
        @response = response
        self
      end

      def session(session)
        @session = session
        self
      end

      def flash(flash)
        @flash = flash
        self        
      end

      def spec(spec)
        @spec = spec
        self
      end

      private

      def model_class
        @subject.is_a?(Class) ? @subject : @subject.class
      end

      def model_name
        model_class.name
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

      def remove_parenthesis(text)
        /#{text.gsub(/\s?\(.*\)$/, '')}/
      end
    end
  end
end
