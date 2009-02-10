module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class ColumnMatcher < Remarkable::Matcher::Base
        arguments :columns
        
        optional  :type, :default, :precision, :limit, :scale, :sql_type
        optional  :primary, :null, :default => true

        assertions :has_column?, :all_options_correct?

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description = if @columns.size == 1
            "have column named :#{@columns[0]}"
          else
            "have columns #{@columns.to_sentence}"
          end
          description << " with options " + @options.inspect unless @options.empty?
          description
        end

        private

        def column_type
          subject_class.columns.detect {|c| c.name == @column.to_s }
        end

        def has_column?
          return true if column_type
          @missing = "#{subject_name} does not have column #{@column}"
          false
        end

        def all_options_correct?
          @options.each do |option, value|
            return false unless option_correct?(option, value)
          end
        end

        def option_correct?(option, expected_value)
          found_value = column_type.instance_variable_get("@#{option.to_s}").to_s

          if found_value == expected_value.to_s
            true
          else
            @missing = ":#{@column} column on table for #{subject_class} does not match option :#{option}, found '#{found_value}' but expected '#{expected_value}'"
            false
          end
        end

        def expectation
          "#{subject_name} to have a column named #{@column}"
        end
      end

      def have_db_column(column, options = {})
        ColumnMatcher.new(column, options)
      end
      
      def have_db_columns(*columns)
        ColumnMatcher.new(*columns)
      end
      
    end
  end
end
