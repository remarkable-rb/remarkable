module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros
      include Matchers

      # Ensure that the belongs_to relationship exists.
      #
      #   should_belong_to :parent
      #
      def should_belong_to(*associations)
        get_options!(associations)
        klass = model_class
        associations.each do |association|
          matcher = belong_to(association)
          it matcher.description do
            assert_accepts(matcher, klass)
          end
        end
      end

      # Ensures that the has_many relationship exists.  Will also test that the
      # associated table has the required columns.  Works with polymorphic
      # associations.
      #
      # Options:
      # * <tt>:through</tt> - association name for <tt>has_many :through</tt>
      # * <tt>:dependent</tt> - tests that the association makes use of the dependent option.
      #
      # Example:
      #   should_have_many :friends
      #   should_have_many :enemies, :through => :friends
      #   should_have_many :enemies, :dependent => :destroy
      #
      def should_have_many(*associations)
        through, dependent = get_options!(associations, :through, :dependent)
        klass = model_class
        associations.each do |association|
          matcher = have_many(association).through(through).dependent(dependent)
          it matcher.description do
            assert_accepts(matcher, klass)
          end
        end
      end

      # Ensure that the has_one relationship exists.  Will also test that the
      # associated table has the required columns.  Works with polymorphic
      # associations.
      #
      # Options:
      # * <tt>:dependent</tt> - tests that the association makes use of the dependent option.
      #
      # Example:
      #   should_have_one :god # unless hindu
      #
      def should_have_one(*associations)
        dependent = get_options!(associations, :dependent)
        klass = model_class
        associations.each do |association|
          matcher = have_one(association).dependent(dependent)
          it matcher.description do
            assert_accepts(matcher, klass)
          end
        end
      end

      # Ensures that the has_and_belongs_to_many relationship exists, and that the join
      # table is in place.
      #
      #   should_have_and_belong_to_many :posts, :cars
      #
      def should_have_and_belong_to_many(*associations)
        get_options!(associations)
        klass = model_class

        associations.each do |association|
          matcher = have_and_belong_to_many(association)
          it matcher.description do
            assert_accepts(matcher, klass)
          end
        end
      end
    end
  end
end
