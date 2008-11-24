module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class DatabaseMatcher
        def initialize(macro, column)
          @macro = macro
          @column = column
          @options = {}
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
          has_column? && 
          type_correct? &&
          is_primary? &&
          default_correct? &&
          precision_correct? &&
          limit_correct? &&
          is_null? &&
          scale_correct? &&
          sql_type_correct?
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description = "have column named :#{@column}"
          description += " with options " + @options.inspect unless @options.empty?
          description
        end

        protected

        def model_class
          @subject
        end

        def has_column?
          if column_type
            true
          else
            @missing = "#{model_class.name} does not have column #{@column}"
            false
          end
        end

        def type_correct?
          option_correct? :type
        end

        def is_primary?
          option_correct? :primary
        end
        
        def default_correct?
          option_correct? :default
        end
        
        def precision_correct?
          option_correct? :precision
        end
        
        def limit_correct?
          option_correct? :limit
        end
        
        def is_null?
          option_correct? :null
        end
        
        def scale_correct?
          option_correct? :scale
        end
        
        def sql_type_correct?
          option_correct? :sql_type
        end

        def option_correct?(option)
          if @options.has_key?(option)
            found_value = column_type.instance_variable_get("@#{option.to_s}").to_s
            expected_value = @options[option].to_s

            unless found_value == expected_value
              @missing = ":#{@column} column on table for #{model_class} does not match option :#{option}, found '#{found_value}' but expected '#{expected_value}'"
              return false
            end
          end
          true
        end

        def column_type
          @column_type ||= model_class.columns.detect {|c| c.name == @column.to_s }
        end

        def expectation
          "#{model_class.name} to have a column named #{@column}"
        end
      end

      def have_db_column(column)
        DatabaseMatcher.new(:column, column)
      end

      # def have_db_columns(*columns)
      #   DatabaseMatcher.new(:column, column)
      # end
      # 
      # def have_indices(*columns)
      #   DatabaseMatcher.new(:index, column)
      # end
      # alias :have_index :have_indices

    end
  end
end
