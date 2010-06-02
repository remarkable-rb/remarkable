module Remarkable
  module RSpec
    module Matchers
      class SingleContainMatcher < Remarkable::Base
        arguments :value, :block => :iterator

        assertions :is_array?, :included?

        optional :allow_nil
        optional :allow_blank
        optional :values, :splat => true

        after_initialize :set_after_initialize

        before_assert do
          @before_assert = true
          @subject.instance_eval(&@iterator) if @iterator
        end

        protected

          def included?
            return true if @subject.include?(@value)

            @expectation = "#{@value} is not included in #{@subject.inspect}"
            false
          end

          def is_array?
            return true if @subject.is_a?(Array)

            @expectation = "subject is a #{subject_name}"
            false
          end

          def default_options
            { :working => true }
          end

          def set_after_initialize
            @after_initialize = true
          end

      end

      def single_contain(*args, &block)
        SingleContainMatcher.new(*args, &block).spec(self)
      end
    end
  end
end
