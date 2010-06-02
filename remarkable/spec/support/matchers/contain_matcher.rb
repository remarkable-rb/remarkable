module Remarkable
  module RSpec
    module Matchers
      class ContainMatcher < Remarkable::Base
        def initialize(*values)
          @values = values
        end

        def matches?(subject)
          @subject = subject

          assert_collection(nil, @values) do |value|
            @value = value
            included?
          end
        end

        def included?
          return true if @subject.include?(@value)

          @expectation = "#{@value} is included in #{@subject.inspect}"
          false
        end
      end

      def contain(*args, &block)
        ContainMatcher.new(*args, &block).spec(self)
      end
    end
  end
end
