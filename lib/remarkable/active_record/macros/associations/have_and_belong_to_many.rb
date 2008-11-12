module Remarkable
  module Syntax

    module RSpec
      class HaveAndBelongToMany
        include Remarkable::Private

        def initialize(*associations)
          get_options!(associations)
          @associations = associations
        end

        def matches?(klass)
          @klass = klass

          begin
            @associations.each do |association|
              reflection = klass.reflect_on_association(association)
              fail("#{klass.name} does not have any relationship to #{association}") unless reflection && reflection.macro == :has_and_belongs_to_many

              table = reflection.options[:join_table]
              fail("table #{table} doesn't exist") unless ::ActiveRecord::Base.connection.tables.include?(table.to_s)
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "should have and belong to many #{@associations.to_sentence}"
        end

        def failure_message
          @failure_message || "expected #{@klass.name} to have and belong to many #{@associations.to_sentence}, but it didn't"
        end

        def negative_failure_message
          "expected #{@klass.name} not to have and belong to many #{@associations.to_sentence}, but it did"
        end
      end

      # Ensures that the has_and_belongs_to_many relationship exists, and that the join
      # table is in place.
      #
      #   it { User.should have_and_belong_to_many(:posts, :cars) }
      #
      def have_and_belong_to_many(*associations)
        Remarkable::Syntax::RSpec::HaveAndBelongToMany.new(*associations)
      end
    end

    module Shoulda
      # Ensures that the has_and_belongs_to_many relationship exists, and that the join
      # table is in place.
      #
      #   should_have_and_belong_to_many :posts, :cars
      #
      def should_have_and_belong_to_many(*associations)
        get_options!(associations)
        klass = model_class

        associations.each do |association|
          it "should have and belong to many #{association}" do
            reflection = klass.reflect_on_association(association)
            fail_with("#{klass.name} does not have any relationship to #{association}") unless reflection
            reflection.macro.should == :has_and_belongs_to_many
            table = reflection.options[:join_table]
            fail_with("table #{table} doesn't exist") unless ::ActiveRecord::Base.connection.tables.include?(table.to_s)
          end
        end
      end
    end

  end
end
