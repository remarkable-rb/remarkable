module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class IndexMatcher < Remarkable::Matcher::Base
        def initialize(*columns)
          load_options(columns)
          @columns = columns
        end

        def unique(value = true)
          @options[:unique] = value
          self
        end

        def matches?(subject)
          @subject = subject
          @expected_uniqueness = @options[:unique] ? 'unique' : 'non-unique'

          assert_matcher_for(@columns) do |column|
            @column = column

            columns = [column].flatten.map(&:to_s)
            index = indices.detect { |ind| ind.columns == columns }

            have_index?(index) && 
            index_is_unique?(index)
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

        def have_index?(index)
          return true if index

          @missing = "#{table_name} does not have an index for #{@column}"
          return false
        end

        def index_is_unique?(index)
          return true if @options[:unique] == index.unique

          @missing = "Expected #{@expected_uniqueness} index but was #{@options[:unique] ? 'non-unique' : 'unique'}."
          return false
        end

        def table_name
          model_class.table_name
        end

        def indices
          @indices ||= ::ActiveRecord::Base.connection.indexes(table_name)
        end

        def expectation
          "have #{@expected_uniqueness} index on #{table_name} for #{@column.inspect}"
        end
        
        def load_options(options)
          @options = {
            :unique => false
          }.merge(options.extract_options!)
        end
      end

      def have_indices(*columns)
        IndexMatcher.new(*columns)
      end

      alias_method :have_index, :have_indices
    end
  end
end
