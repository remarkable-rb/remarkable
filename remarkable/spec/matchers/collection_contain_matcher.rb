module Remarkable
  module Specs
    module Matchers
      class CollectionContainMatcher < Remarkable::Base
        arguments :collection => :values, :as => :value

        optional :working
        default_options :working => true

        single_assertion :is_array? do
          @subject.is_a?(Array)
        end

        assertion :included? do
          return @subject.include?(@value), :more => 'ERROR: '
        end

        after_initialize do
          @after_initialize = true
        end

        before_assert do
          @before_assert = true
        end
      end

      def collection_contain(*args)
        CollectionContainMatcher.new(*args).spec(self)
      end
    end
  end
end
