module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class IndexMatcher < Remarkable::Matcher::Base
        INDEX_TYPES = { true => "unique", false => "non-unique" }

        arguments :columns
        optional  :unique, :default => true

        assertions :index_exists?, :correct_unique?

        def table_name=(table_name)
          @table_name = table_name
        end

        def failure_message
          "Expected to #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect to #{expectation}"
        end

        def description
          "have #{index_type} index on #{table_name} for #{@columns.inspect}"
        end

        protected

        def after_initialize
          @expected_uniqueness = @options[:unique] ? 'unique' : 'non-unique'
        end

        def index_exists?
          return true if matched_index

          @missing = "#{table_name} does not have an index for #{@column}"
          return false
        end

        def correct_unique?
          return true unless [true, false].include?(@options[:unique])
          return true if @options[:unique] == matched_index.unique

          @missing = "Expected #{index_type} index but was #{INDEX_TYPES[!@options[:unique]]}."
          return false
        end

        def matched_index
          columns = [@column].flatten.map(&:to_s)
          indexes.detect { |ind| ind.columns == columns }
        end

        def index_type
          INDEX_TYPES[@options[:unique]] || "an"
        end

        def table_name
          @table_name ||= subject_class.table_name
        end

        def indexes
          @indexes ||= ::ActiveRecord::Base.connection.indexes(table_name)
        end

        def expectation
          "have #{index_type} index on #{table_name} for #{@column.inspect}"
        end

      end

      # Ensures the database column has specified index.
      #
      # Options:
      # * <tt>unique</tt> - when supplied, tests if the index is unique or not
      #
      # Example:
      #   it { should have_index(:ssn).unique(true) }
      #
      def have_indices(*columns)
        IndexMatcher.new(*columns)
      end
      alias_method :have_index, :have_indices

    end
  end
end
