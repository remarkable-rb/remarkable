module Remarkable
  module ActiveRecord
    module Matchers
      class AssociationMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :macro, :collection => :associations, :as => :association

        optionals :through, :class_name, :foreign_key, :dependent, :join_table, :as
        optionals :uniq, :readonly, :validate, :autosave, :polymorphic, :counter_cache, :default => true

        # Stores optionals declared above in a CONSTANT to generate assertions
        ASSOCIATION_OPTIONS = self.matcher_optionals

        collection_assertions :association_exists?, :macro_matches?, :through_exists?, :source_exists?,
                              :join_table_exists?, :foreign_key_exists?, :polymorphic_exists?,
                              :counter_cache_exists?

        protected

          def association_exists?
            reflection
          end

          def macro_matches?
            reflection.macro == @macro
          end

          def through_exists?
            return true unless @options.key?(:through)
            reflection.through_reflection rescue false
          end

          def source_exists?
            return true unless @options.key?(:through)
            reflection.source_reflection rescue false
          end

          def join_table_exists?
            return true unless reflection.macro == :has_and_belongs_to_many
            ::ActiveRecord::Base.connection.tables.include?(reflection.options[:join_table])
          end

          def foreign_key_exists?
            return true unless foreign_key_table
            table_has_column?(foreign_key_table, reflection_foreign_key)
          end

          def polymorphic_exists?
            return true unless @options[:polymorphic]
            table_has_column?(subject_class.table_name, reflection_foreign_key.sub(/_id$/, '_type'))
          end

          def counter_cache_exists?
            return true unless @options[:counter_cache]
            table_has_column?(reflection.klass.table_name, reflection.counter_cache_column.to_s)
          end

          ASSOCIATION_OPTIONS.each do |option|
            collection_assertion :"#{option}_matches?"

            class_eval <<-METHOD, __FILE__, __LINE__
              def #{option}_matches?
                return true unless @options.key?(#{option.inspect})
                actual_value = respond_to?(:reflection_#{option}, true) ? reflection_#{option} : reflection.options[#{option.inspect}].to_s

                return true if @options[#{option.inspect}].to_s == actual_value
              end
            METHOD
          end

        private

          def reflection
            @reflection ||= subject_class.reflect_on_association(@association.to_sym)
          end

          # Rescue nil to avoid raising errors in invalid through associations
          def reflection_class_name
            reflection.class_name.to_s rescue nil
          end

          def reflection_foreign_key
            reflection.primary_key_name.to_s
          end

          def table_has_column?(table_name, column)
            ::ActiveRecord::Base.connection.columns(table_name, 'Remarkable column retrieval').any?{|c| c.name == column }
          end

          # In through we don't check the foreign_key, because it's spread
          # accross the through and the source reflection which should be tested
          # with their own macros.
          #
          # In cases a join table exists (has_and_belongs_to_many and through
          # associations), we check the foreign key in the join table.
          #
          # On belongs to, the foreign_key is in the subject class table and in
          # other cases it's on the reflection class table.
          #
          def foreign_key_table
            if reflection.options.key?(:through)
              nil
            elsif reflection.macro == :has_and_belongs_to_many
              reflection.options[:join_table]
            elsif reflection.macro == :belongs_to
              subject_class.table_name
            else
              reflection.klass.table_name
            end
          end

          def interpolation_options
            options = { :macro => Remarkable.t(@macro, :scope => matcher_i18n_scope, :default => @macro.to_s) }

            if @subject && reflection
              options.merge!(
                :actual_macro         => Remarkable.t(reflection.macro, :scope => matcher_i18n_scope, :default => reflection.macro.to_s),
                :subject_table        => subject_class.table_name.inspect,
                :reflection_table     => reflection.klass.table_name.inspect,
                :foreign_key_table    => foreign_key_table.inspect,
                :polymorphic_column   => reflection_foreign_key.sub(/_id$/, '_type').inspect,
                :counter_cache_column => reflection.counter_cache_column.to_s.inspect
              ) rescue nil # rescue to allow specs to run properly

              ASSOCIATION_OPTIONS.each do |option|
                value_to_compare = respond_to?(:"reflection_#{option}", true) ? send(:"reflection_#{option}") : reflection.options[option].to_s
                options[:"actual_#{option}"] = value_to_compare.inspect
              end

            end

            options
          end
      end

      # Ensure that the belongs_to relationship exists. Will also test that the
      # subject table has the association_id column.
      #
      # == Options
      #
      # * <tt>:class_name</tt> - the expected associted class name.
      # * <tt>:foreign_key</tt> - the expected foreign key in the subject table.
      # * <tt>:dependent</tt> - the expected dependent value for the association.
      # * <tt>:readonly</tt> - checks wether readonly is true or false.
      # * <tt>:validate</tt> - checks wether validate is true or false.
      # * <tt>:autosave</tt> - checks wether autosave is true or false.
      # * <tt>:counter_cache</tt> - the expected dependent value for the association.
      #   It also checks if the column actually exists in the table.
      # * <tt>:polymorphic</tt> - if the association should be polymorphic or not.
      #   When true it also checks for the association_type column in the subject table.
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
