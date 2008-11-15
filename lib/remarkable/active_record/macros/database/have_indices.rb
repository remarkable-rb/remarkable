module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class HaveIndices
          def initialize(*columns)
            @columns = columns
          end

          def matches?(klass)
            @table = klass.table_name
            indices = ::ActiveRecord::Base.connection.indexes(@table).map(&:columns)

            @columns.each do |column|
              columns = [column].flatten.map(&:to_s)
              return false unless indices.include?(columns)
            end
          end

          def description
            "have index on #{@table} for #{pretty_columns}"
          end

          def failure_message
            "expected to have index on #{@table} for #{pretty_columns}, but it didn't"
          end

          def negative_failure_message
            "expected not to have index on #{@table} for #{pretty_columns}, but it did"
          end

          private

          def pretty_columns
            @columns.collect { |col| col.is_a?(Array) ? "[#{col.join(', ')}]" : col }.to_sentence
          end    
        end

        # Ensures that there are DB indices on the given columns or tuples of columns.
        # Also aliased to should_have_index for readability
        #
        #   it { should have_indices(:email, :name, [:commentable_type, :commentable_id]) }
        #   it { should have_index(:age) }
        # 
        def have_indices(*columns)
          Remarkable::ActiveRecord::Syntax::RSpec::HaveIndices.new(*columns)
        end

        alias :have_index :have_indices
      end

      module Shoulda
        # Ensures that there are DB indices on the given columns or tuples of columns.
        # Also aliased to should_have_index for readability
        #
        #   should_have_indices :email, :name, [:commentable_type, :commentable_id]
        #   should_have_index :age
        #
        def should_have_indices(*columns)
          table = model_class.table_name
          indices = ::ActiveRecord::Base.connection.indexes(table).map(&:columns)

          columns.each do |column|
            it "should have index on #{table} for #{column.inspect}" do
              columns = [column].flatten.map(&:to_s)
              assert_contains(indices, columns).should be_true
            end
          end
        end

        alias_method :should_have_index, :should_have_indices
      end

    end
  end
end
