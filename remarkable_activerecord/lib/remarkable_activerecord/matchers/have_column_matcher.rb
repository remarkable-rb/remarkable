module Remarkable
  module ActiveRecord
    module Matchers
      class HaveColumnMatcher < Remarkable::ActiveRecord::Base
        arguments :collection => :columns, :as => :column

        optional :type, :default, :precision, :limit, :scale, :sql_type
        optional :primary, :null, :default => true

        collection_assertions :column_exists?, :options_match?

        before_assert do
          @options.each{|k,v| @options[k] = v.to_s}
        end

        protected

          def column_exists?
            !column_type.nil?
          end

          def options_match?
            actual = get_column_options(column_type, @options.keys)
            return actual == @options, :actual => actual.inspect
          end

          def column_type
            subject_class.columns.detect {|c| c.name == @column.to_s }
          end

          def get_column_options(column, keys)
            keys.inject({}) do |hash, key|
              hash[key] = column.instance_variable_get("@#{key}").to_s
              hash
            end
          end

          def interpolation_options
            { :options => @options.inspect }
          end

      end

      # Ensures that a column of the database actually exists.
      #
      # == Options
      # 
      # * All options available in migrations are available:
      #
      #   :type, :default, :precision, :limit, :scale, :sql_type, :primary, :null
      #
      # == Examples
      #
      #   should_have_db_column :name, :type => :string, :default => ''
      #
      #   it { should have_db_column(:name, :type => :string) }
      #   it { should have_db_column(:name).type(:string) }
      # 
      def have_column(*args)
        HaveColumnMatcher.new(*args).spec(self)
      end
      alias :have_columns :have_column

    end
  end
end
