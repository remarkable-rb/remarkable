module Remarkable
  class HaveDbColumn < Remarkable::Database
    def initialize(name, opts)
      @name = name
      @opts = opts
    end

    def matches?(klass)
      @klass = klass

      column = klass.columns.detect {|c| c.name == @name.to_s }
      unless column
        @message = "#{klass.name} does not have column #{@name}"
        return false
      end

      @opts.each do |k, v|
        unless column.instance_variable_get("@#{k}").to_s == v.to_s
          @message = ":#{@name} column on table for #{klass} does not match option :#{k}"
          return false
        end
      end
    end

    def description
      test_name = "have column named :#{@name}"
      test_name += " with options " + @opts.inspect unless @opts.empty?
      test_name
    end

    def failure_message
      test_name = "expected #{@klass} to have column named :#{@name}"
      test_name += " with options " + @opts.inspect unless @opts.empty?
      test_name += ", but it didn't"

      @message || test_name
    end

    def negative_failure_message
      test_name = "expected #{@klass} not to have column named :#{@name}"
      test_name += " with options " + @opts.inspect unless @opts.empty?
      test_name += ", but it did"
      test_name
    end
  end
end

# Ensure that the given column is defined on the models backing SQL table.  The options are the same as
# the instance variables defined on the column definition:  :precision, :limit, :default, :null,
# :primary, :type, :scale, and :sql_type.
#
#   it { User.should have_db_column(:email, :type => "string",  :default => nil,    :precision => nil,  :limit => 255,
#                                           :null => true,      :primary => false,  :scale => nil,      :sql_type => 'varchar(255)') }
# 
def have_db_column(name, opts = {})
  Remarkable::HaveDbColumn.new(name, opts)
end
