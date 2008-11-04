module Remarkable
  class HaveDbColumns < Remarkable::Database
    def initialize(*columns)
      @column_type = get_options!(columns, :type)
      @columns = columns
    end

    def matches?(klass)
      @klass = klass

      @columns.each do |name|
        column = klass.columns.detect {|c| c.name == name.to_s }
        
        unless column
          @message = "#{klass.name} does not have column #{name}"
          return false
        end        
      end
    end

    def description
      test_name = "have columns #{@columns.to_sentence}"
      test_name += " of type #{@column_type}" if @column_type
      test_name
    end

    def failure_message
      @message || "expected #{@klass} to have_db_columns #{@columns.to_sentence}, but it didn't"
    end

    def negative_failure_message
      test_name = "expected not to have columns #{@columns.to_sentence}"
      test_name += " of type #{@column_type}" if @column_type
      test_name += ", but it did"
      test_name
    end
  end
end

# Ensure that the given columns are defined on the models backing SQL table.
#
#   should_have_db_columns :id, :email, :name, :created_at
#
def have_db_columns(*columns)
  Remarkable::HaveDbColumns.new(*columns)
end
