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
        fail("#{klass.name} does not have column #{name}") unless column
      end
    end

    def description
      message = "have columns #{@columns.to_sentence}"
      message += " of type #{@column_type}" if @column_type
      message
    end

    def failure_message
      message = "expected to have columns #{@columns.to_sentence}"
      message += " of type #{@column_type}" if @column_type
      message += ", but it didn't"
            
      @failure_message || message
    end

    def negative_failure_message
      message = "expected not to have columns #{@columns.to_sentence}"
      message += " of type #{@column_type}" if @column_type
      message += ", but it did"
      message
    end
  end
end

# Ensure that the given columns are defined on the models backing SQL table.
#
#   it { User.should have_db_columns(:id, :email, :name, :created_at) }
#
def have_db_columns(*columns)
  Remarkable::HaveDbColumns.new(*columns)
end
