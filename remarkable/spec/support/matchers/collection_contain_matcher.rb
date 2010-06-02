module Remarkable
  module RSpec
    module Matchers
      class CollectionContainMatcher < Remarkable::Base
        arguments :collection => :values, :as => :value

        optional :working, :allow_nil
        default_options :working => true

        assertion :is_array? do
          @subject.is_a?(Array)
        end

        collection_assertion :included? do
          return @subject.include?(@value), :more => 'that '
        end

        after_initialize do
          @after_initialize = true
        end

        before_assert do
          @before_assert = true
        end
      end

      def collection_contain(*args, &block)
        CollectionContainMatcher.new(*args, &block).spec(self)
      end
    end
  end
end
