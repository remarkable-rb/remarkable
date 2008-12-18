module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class IndexMatcher < Remarkable::Matcher::Base
        def initialize(*columns)
          columns.extract_options!
          @columns = columns
        end
       
        def matches?(subject)
          @subject = subject
          
          assert_matcher_for(@columns) do |column|
            @column = column
            has_index_for?
          end
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end

        def description
          "have index on #{table_name} for #{@columns.to_sentence}"
        end

        protected

        def has_index_for?
          columns = [@column].flatten.map(&:to_s)
          if indices.include?(columns)
            true
          else
            @missing = "table #{table_name} does not have an index on column"
            @missing += (columns.size == 1) ? " #{columns}" : "s #{columns.inspect}"
            false
          end
        end
        
        def table_name
          model_class.table_name
        end
        
        def indices
          @indices ||= ::ActiveRecord::Base.connection.indexes(table_name).map(&:columns)
        end

        def expectation
          "have index on #{table_name} for #{@column}"
        end
      end

      def have_indices(*columns)
        IndexMatcher.new(*columns)
      end
      
      alias_method :have_index, :have_indices
    end
  end
end
