module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      class ColumnMatcher < Remarkable::Matcher::Base
        arguments :columns
        
        optional  :type, :default, :precision, :limit, :scale, :sql_type
        optional  :primary, :null, :default => true

        # TODO: remove it
        def of_type(type)
          warn "[DEPRECATION] option of_type is deprecated in have_db_column. Use type instead."
          @options[:type] = type
          self
        end

        # Method used to load all options via hash.
        # (:type, :default, :precision, :limit, :scale, :sql_type, :primary, :null)
        # 
        def with_options(opts = {})
          @options.merge!(opts)
          self
        end

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

      # Ensures that a column of the database actually exists.
      #
      # Options:
      # * <tt>type</tt> - database column types like :string, :integer, etc.
      # 
      # * All options available in migrations are also available here.
      #   (.type, .default, .precision, .limit, .scale, .sql_type, .primary, .null)
      # 
      # * <tt>with_options</tt> - option used to load the above options via hash
      #   (:type => :string, :primary => true, etc.)
      #
      # Example:
      # it { should have_db_column(:name).type(:string) }
      # it { should have_db_column(:age).with_options(:type => :integer) }
      # it { should_not have_db_column(:salary) }
      # 
      def have_db_column(column, options = {})
        ColumnMatcher.new(column, options)
      end

      # Alias for #have_db_column
      # 
      def have_db_columns(*columns)
        ColumnMatcher.new(*columns)
      end
      
    end
  end
end
