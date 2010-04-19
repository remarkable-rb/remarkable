module Remarkable
  module ActiveRecord
    module Matchers
      class HaveIndexMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :columns, :as => :column

        optional :table_name
        optional :unique, :default => true

        collection_assertions :index_exists?, :is_unique?

        protected

          def index_exists?
            !matched_index.nil?
          end

          def is_unique?
            return true unless @options.key?(:unique)
            return @options[:unique] == matched_index.unique, :actual => matched_index.unique
          end

          def matched_index
            columns = [@column].flatten.map(&:to_s)
            indexes.detect { |ind| ind.columns == columns }
          end

          def indexes
            @indexes ||= ::ActiveRecord::Base.connection.indexes(current_table_name)
          end

          def interpolation_options
            @subject ? { :table_name => current_table_name } : {}
          end

        private

          def current_table_name
            @options[:table_name] || subject_class.table_name
          end

      end

      # Ensures the database column has specified index.
      #
      # == Options
      #
      # * <tt>unique</tt> - when supplied, tests if the index is unique or not
      # * <tt>table_name</tt> - when supplied, tests if the index is defined for the given table
      #
      # == Examples
      #
      #   it { should have_index(:ssn).unique(true) }
      #   it { should have_index([:name, :email]).unique(true) }
      #
      #   should_have_index :ssn, :unique => true, :limit => 9, :null => false
      #
      #   should_have_index :ssn do |m|
      #     m.unique
      #     m.limit = 9
      #     m.null = false
      #   end
      #
      def have_index(*args, &block)
        HaveIndexMatcher.new(*args, &block).spec(self)
      end
      alias :have_indices    :have_index
      alias :have_db_index   :have_index
      alias :have_db_indices :have_index

    end
  end
end
