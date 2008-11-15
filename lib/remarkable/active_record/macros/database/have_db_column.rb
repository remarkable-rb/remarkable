module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class HaveDbColumn
          def initialize(name, opts)
            @name = name
            @opts = opts
          end

          def matches?(klass)
            @klass = klass

            column = klass.columns.detect {|c| c.name == @name.to_s }
            fail("#{klass.name} does not have column #{@name}") unless column

            @opts.each do |k, v|
              fail(":#{@name} column on table for #{klass} does not match option :#{k}") unless column.instance_variable_get("@#{k}").to_s == v.to_s
            end
          end

          def description
            message = "have column named :#{@name}"
            message += " with options " + @opts.inspect unless @opts.empty?
            message
          end

          def failure_message
            message = "expected #{@klass.name} to have column named :#{@name}"
            message += " with options " + @opts.inspect unless @opts.empty?
            message += ", but it didn't"

            @failure_message || message
          end

          def negative_failure_message
            message = "expected #{@klass.name} not to have column named :#{@name}"
            message += " with options " + @opts.inspect unless @opts.empty?
            message += ", but it did"
            message
          end
        end

        # Ensure that the given column is defined on the models backing SQL table.  The options are the same as
        # the instance variables defined on the column definition:  :precision, :limit, :default, :null,
        # :primary, :type, :scale, and :sql_type.
        #
        #   it { should have_db_column(:email, :type => "string",  :default => nil,    :precision => nil,  :limit => 255,
        #                                           :null => true,      :primary => false,  :scale => nil,      :sql_type => 'varchar(255)') }
        # 
        def have_db_column(name, opts = {})
          Remarkable::ActiveRecord::Syntax::RSpec::HaveDbColumn.new(name, opts)
        end
      end

      module Shoulda
        # Ensure that the given column is defined on the models backing SQL table.  The options are the same as
        # the instance variables defined on the column definition:  :precision, :limit, :default, :null,
        # :primary, :type, :scale, and :sql_type.
        #
        #   should_have_db_column :email, :type => "string", :default => nil,   :precision => nil, :limit    => 255,
        #                                 :null => true,     :primary => false, :scale     => nil, :sql_type => 'varchar(255)'
        #
        def should_have_db_column(name, opts = {})
          klass = model_class
          test_name = "should have column named :#{name}"
          test_name += " with options " + opts.inspect unless opts.empty?
          it test_name do
            column = klass.columns.detect {|c| c.name == name.to_s }
            fail_with("#{klass.name} does not have column #{name}") unless column
            opts.each do |k, v|
              unless v.to_s == column.instance_variable_get("@#{k}").to_s
                fail_with(":#{name} column on table for #{klass} does not match option :#{k}")
              end
            end
          end
        end
      end

    end
  end
end
