module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class HaveDbColumns
          include Remarkable::Private

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

        # Ensure that the given columns are defined on the models backing SQL table.
        #
        #   it { should have_db_columns(:id, :email, :name, :created_at) }
        #
        def have_db_columns(*columns)
          Remarkable::ActiveRecord::Syntax::RSpec::HaveDbColumns.new(*columns)
        end
      end

      module Shoulda
        # Ensure that the given columns are defined on the models backing SQL table.
        #
        #   should_have_db_columns :id, :email, :name, :created_at
        #
        def should_have_db_columns(*columns)
          column_type = get_options!(columns, :type)
          klass = model_class
          columns.each do |name|
            test_name = "should have column #{name}"
            test_name += " of type #{column_type}" if column_type
            it test_name do
              column = klass.columns.detect {|c| c.name == name.to_s }
              fail_with("#{klass.name} does not have column #{name}") unless column
            end
          end
        end
      end

    end
  end
end
