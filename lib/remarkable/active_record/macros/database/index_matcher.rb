module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class IndexMatcher
        def initialize(*columns)
          columns.extract_options!
          @columns = columns
        end
       
        def matches?(subject)
          @subject = subject
          
          @columns.each do |column|
            return false unless has_index_for?(column)
          end
          
          true
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end

        def description
          expectation
        end

        protected

        def has_index_for?(column)
          columns = [column].flatten.map(&:to_s)
          if indices.include?(columns)
            true
          else
            @missing = "table #{table_name} does not have an index on column"
            @missing += (columns.size == 1) ? " #{columns}" : "s #{columns.inspect}"
            false
          end
        end

        def model_class
          @subject
        end
        
        def table_name
          model_class.table_name
        end
        
        def indices
          @indices ||= ::ActiveRecord::Base.connection.indexes(table_name).map(&:columns)
        end

        def expectation
          if @columns.size == 1
            "have index on #{table_name} for #{@columns[0].inspect}"
          else
            "have indices on #{table_name} for #{@columns.inspect}"
          end
        end
      end

      def have_indices(*columns)
        IndexMatcher.new(*columns)
      end
      
      alias_method :have_index, :have_indices
      
    end
  end
end
