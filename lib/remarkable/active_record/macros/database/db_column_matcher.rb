module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class DBColumnMatcher < Remarkable::Matcher::Base
        def initialize(*columns)
          @options = columns.extract_options!
          @columns  = columns
        end

        def type(type)
          @options[:type] = type
          self
        end

        def primary(value = true)
          @options[:primary] = value
          self
        end

        def default(default)
          @options[:default] = default
          self
        end

        def precision(precision)
          @options[:precision] = precision
          self
        end

        def limit(limit)
          @options[:limit] = limit
          self
        end

        def null(value = true)
          @options[:null] = value
          self
        end

        def scale(scale)
          @options[:scale] = scale
          self
        end

        def sql_type(sql_type)
          @options[:sql_type] = sql_type
          self
        end

        def matches?(subject)
          @subject = subject
          
          assert_matcher_for(@columns) do |column|
            @column = column
            has_column? && all_options_correct?
          end
        end

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

        protected

        def column_type
          model_class.columns.detect {|c| c.name == @column.to_s }
        end

        def has_column?
          return true if column_type
          @missing = "#{model_name} does not have column #{@column}"
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
            @missing = ":#{@column} column on table for #{model_class} does not match option :#{option}, found '#{found_value}' but expected '#{expected_value}'"
            false
          end
        end

        def expectation
          "#{model_name} to have a column named #{@column}"
        end
      end

      def have_db_column(column, options = {})
        DBColumnMatcher.new(column, options)
      end
      
      def have_db_columns(*columns)
        DBColumnMatcher.new(*columns)
      end
      
    end
  end
end
