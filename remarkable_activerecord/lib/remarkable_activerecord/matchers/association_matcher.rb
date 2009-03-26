module Remarkable
  module ActiveRecord
    module Matchers

      class AssociationMatcher < Remarkable::Base
        ASSOCIATION_OPTIONS = [ :through, :class_name, :foreign_key, :dependent, :join_table,
                                :uniq, :readonly, :validate, :autosave, :counter_cache, :polymorphic ]

        arguments :macro, :collection => :associations, :as => :association

        collection_assertions :association_exists?, :macro_matches?, :through_exists?,
                              :join_table_exists?, :foreign_key_exists?, :counter_cache_exists?

        protected

          def association_exists?
            reflection
          end

          def macro_matches?
            reflection.macro == @macro
          end

          def through_exists?
            return true unless @options.key?(:through)
            subject_class.reflect_on_association(@options[:through])
          end

          def join_table_exists?
            return true unless has_join_table?
            ::ActiveRecord::Base.connection.tables.include?(join_table)
          end

          # In cases a join table exists (has_and_belongs_to_many and through
          # associations), we check the foreign key in the join table.
          #
          # On belongs to, the foreign_key is in the subject class table and in
          # other cases it's on the reflection class table.
          #
          def foreign_key_exists?
            if has_join_table?
              table_has_foreign_key?(join_table)
            elsif reflection.belongs_to?
              table_has_foreign_key?(subject_class.table_name)
            else
              table_has_foreign_key?(reflection.klass.table_name)
            end
          end

          def counter_cache_exists?
            return true unless @options[:counter_cache]
            table_has_column?(subject_class.table_name, reflection.counter_cache_column)
          end

          ASSOCIATION_OPTIONS.each do |option|
            optional             option, :default => true
            collection_assertion :"#{option}_matches?"

            class_eval <<-METHOD, __FILE__, __LINE__
              def #{option}_matches?
                return true unless @options.key?(#{option.inspect})
                actual_value = respond_to?(#{option.inspect}) ? #{option} : reflection.options[#{option.inspect}].to_s

                return true if @options[#{option.inspect}].to_s == actual_value
              end
            METHOD
          end

        private

          def table_has_foreign_key?(table_name)
            table_has_column?(table_name, foreign_key)
          end

          def table_has_column?(table_name, column)
            ::ActiveRecord::Base.connection.columns(table_name, 'Remarkable column retrieval').include?(column)
          end

          def reflection
            @reflection ||= subject_class.reflect_on_association(@association)
          end

          def class_name
            reflection.class_name.to_s
          end

          def foreign_key
            reflection.primary_key_name.to_s
          end

          def has_join_table?
            @options.key?(:through) || @macro == :has_and_belongs_to_many
          end

          def join_table
            (reflection.options[:join_table] || reflection.options[:through]).to_s
          end

          def interpolation_options
            options = { :macro => Remarkable.t(@macro, :scope => matcher_i18n_scope, :default => @macro.to_s) }

            if reflection
              ASSOCIATION_OPTIONS.each do |option|
                value_to_compare = respond_to?(option) ? option : reflection.options[option].to_s
                options[:"actual_#{option}"] = value_to_compare.inspect
              end

              options[:actual_macro] = Remarkable.t(reflection.macro, :scope => matcher_i18n_scope, :default => reflection.macro.to_s).inspect
              options[:actual_counter_cache] = reflection.counter_cache_column.inspect
            end

            options
          end

      end

      # Ensure that the belongs_to relationship exists. Will also test that the
      # subject table has the required columns.
      #
      # == Options
      #
      # * <tt>:class_name</tt> - the expected associted class name.
      # * <tt>:foreign_key</tt> - the expected foreign key in the subject table.
      # * <tt>:dependent</tt> - the expected dependent value for the association.
      # * <tt>:polymorphic</tt> - if the association should be polymorphic or not.
      # * <tt>:readonly</tt> - checks wether readonly is true or false.
      # * <tt>:validate</tt> - checks wether validate is true or false.
      # * <tt>:autosave</tt> - checks wether autosave is true or false.
      # * <tt>:counter_cache</tt> - the expected dependent value for the association.
      #   It also checks if the column actually exists in the table.
      #
      # == Examples
      #
      #   should_belong_to :parent, :polymorphic => true
      #   it { should belong_to(:parent) }
      #
      def belong_to(*associations)
        AssociationMatcher.new(:belongs_to, *associations).spec(self)
      end

      # Ensures that the has_and_belongs_to_many relationship exists, if the join
      # table is in place and if the foreign_key column exists.
      #
      # == Options
      #
      # * <tt>:class_name</tt>  - the expected associted class name.
      # * <tt>:join_table</tt>  - the expected join table name.
      # * <tt>:foreign_key</tt> - the expected foreign key in the association table.
      # * <tt>:uniq</tt>     - checks wether uniq is true or false.
      # * <tt>:readonly</tt> - checks wether readonly is true or false.
      # * <tt>:validate</tt> - checks wether validate is true or false.
      # * <tt>:autosave</tt> - checks wether autosave is true or false.
      #
      # == Examples
      #
      #  should_have_and_belong_to_many :posts, :cars
      #  it{ should have_and_belong_to_many :posts, :cars }
      #
      def have_and_belong_to_many(*associations)
        AssociationMatcher.new(:has_and_belongs_to_many, *associations).spec(self)
      end

      # Ensures that the has_many relationship exists. Will also test that the
      # associated table has the required columns. It works by default with 
      # polymorphic association (:as does not have to be supplied).
      #
      # == Options
      #
      # * <tt>:class_name</tt>  - the expected associted class name.
      # * <tt>:through</tt>     - the expected join model which to perform the query.
      #   It also checks if the through table exists.
      # * <tt>:foreign_key</tt> - the expected foreign key in the associated table.
      #   When used with :through, it will check for the foreign key in the join table.
      # * <tt>:dependent</tt>   - the expected dependent value for the association.
      # * <tt>:uniq</tt>     - checks wether uniq is true or false.
      # * <tt>:readonly</tt> - checks wether readonly is true or false.
      # * <tt>:validate</tt> - checks wether validate is true or false.
      # * <tt>:autosave</tt> - checks wether autosave is true or false.
      #
      # == Examples
      #
      #   should_have_many :friends
      #   should_have_many :enemies, :through => :friends
      #   should_have_many :enemies, :dependent => :destroy
      #
      #   it{ should have_many(:friends) }
      #   it{ should have_many(:enemies, :through => :friends) }
      #   it{ should have_many(:enemies, :dependent => :destroy) }
      #
      def have_many(*associations)
        AssociationMatcher.new(:has_many, *associations).spec(self)
      end

      # Ensures that the has_many relationship exists. Will also test that the
      # associated table has the required columns. It works by default with 
      # polymorphic association (:as does not have to be supplied).
      #
      # == Options
      #
      # * <tt>:class_name</tt>  - the expected associted class name.
      # * <tt>:through</tt>     - the expected join model which to perform the query.
      #   It also checks if the through table exists.
      # * <tt>:foreign_key</tt> - the expected foreign key in the associated table.
      #   When used with :through, it will check for the foreign key in the join table.
      # * <tt>:dependent</tt>   - the expected dependent value for the association.
      # * <tt>:uniq</tt>     - checks wether uniq is true or false.
      # * <tt>:readonly</tt> - checks wether readonly is true or false.
      # * <tt>:validate</tt> - checks wether validate is true or false.
      # * <tt>:autosave</tt> - checks wether autosave is true or false.
      #
      # == Examples
      #
      #  should_have_one :universe
      #  it{ should have_one(:universe) }
      #
      def have_one(*associations)
        AssociationMatcher.new(:has_one, *associations).spec(self)
      end

    end
  end
end
