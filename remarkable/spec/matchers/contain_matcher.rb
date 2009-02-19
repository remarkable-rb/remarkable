module Remarkable
  module Specs
    module Matchers
      class ContainMatcher < Remarkable::Base
        def initialize(*values)
          @values = values
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@values) do |value|
            @value = value
            included?
          end
        end

        def included?
          return true if @subject.include?(@value)

          @missing = "#{@value} is not included in #{@subject.inspect}"
          false
        end
      end

      def contain(*args)
        ContainMatcher.new(*args)
      end
    end
  end
end
