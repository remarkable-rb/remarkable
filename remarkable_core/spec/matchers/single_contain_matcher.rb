module Remarkable
  module Specs
    module Matchers
      class SingleContainMatcher < Remarkable::Base
        arguments :value, :block => :iterator

        single_assertions :is_array?, :included?

        def description
          "contain #{@values.join(', ')}"
        end

        def expectation
          "#{@value} is included in #{@subject.inspect}"
        end

        protected

          def included?
            return true if @subject.include?(@value)

            @missing = "#{@value} is not included in #{@subject.inspect}"
            false
          end

          def is_array?
            return true if @subject.is_a?(Array)

            @missing = "subject is a #{subject_name}"
            false
          end

          def after_initialize
            @after_initialize = true
          end

          def before_assert
            @before_assert = true
            @iterator.call(@subject) if @iterator
          end

          def default_options
            { :working => true }
          end

      end

      def single_contain(*args, &block)
        SingleContainMatcher.new(*args, &block)
      end
    end
  end
end
