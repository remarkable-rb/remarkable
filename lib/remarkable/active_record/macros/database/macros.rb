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
        it matcher.description do
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
        it matcher.description do
          assert_accepts(matcher, klass)
        end
      end
    end
  end
end
