module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      # Ensure that the given columns are defined on the models backing SQL table.
      #
      #   should_have_db_columns :id, :email, :name, :created_at
      #
      def should_have_db_columns(*columns)
        klass = model_class
        matcher = have_db_columns(*columns)
        it "should #{matcher.description}" do
          assert_accepts(matcher, klass)
        end
      end

      # Ensure that the given column is defined on the models backing SQL table.  The options are the same as
      # the instance variables defined on the column definition:  :precision, :limit, :default, :null,
      # :primary, :type, :scale, and :sql_type.
      #
      #   should_have_db_column :email, :type => "string", :default => nil,   :precision => nil, :limit    => 255,
      #                                 :null => true,     :primary => false, :scale     => nil, :sql_type => 'varchar(255)'
      #
      def should_have_db_column(name, options = {})
        klass = model_class
        matcher = have_db_column(name, options)
        it "should #{matcher.description}" do
          assert_accepts(matcher, klass)
        end
      end
      
      # Ensures that there are DB indices on the given columns or tuples of columns.
      # Also aliased to should_have_index for readability
      #
      #   should_have_indices :email, :name, [:commentable_type, :commentable_id]
      #   should_have_index :age
      #
      def should_have_indices(*columns)
        klass = model_class
        columns.each do |column|
          matcher = have_index(column)
          it "should have index on #{klass.table_name} for #{column.inspect}" do
            assert_accepts(matcher, klass)
          end
        end
      end

      alias_method :should_have_index, :should_have_indices
    end
  end
end
