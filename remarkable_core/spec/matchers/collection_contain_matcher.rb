module Remarkable
  module Specs
    module Matchers
      class CollectionContainMatcher < Remarkable::Base
        arguments :collection => :values, :as => :value

        default_options :working => true

        single_assertion :is_array? do
          @subject.is_a?(Array)
        end

        assertion :included? do
          @subject.include?(@value)
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
