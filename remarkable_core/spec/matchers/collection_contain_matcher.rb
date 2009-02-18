module Remarkable
  module Specs
    module Matchers
      class CollectionContainMatcher < Remarkable::Base
        arguments :collection => :values, :as => :value

        default_options :working => true

        single_assertion :is_array? do
          return true if @subject.is_a?(Array)

          @missing = "subject is a #{subject_name}"
          false
        end

        assertion :included? do
          return true if @subject.include?(@value)

          @missing = "#{@value} is not included in #{@subject.inspect}"
          false
        end

        after_initialize do
          @after_initialize = true
        end

        before_assert do
          @before_assert = true
        end
      end

      def collection_contain(*args)
        CollectionContainMatcher.new(*args)
      end
    end
  end
end
