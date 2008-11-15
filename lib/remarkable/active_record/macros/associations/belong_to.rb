module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class BelongTo
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
                fail("#{klass.name} does not have any relationship to #{association}") unless reflection && reflection.macro == :belongs_to

                unless reflection.options[:polymorphic]
                  associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize
                  fk = reflection.options[:foreign_key] || reflection.primary_key_name
                  fail("#{klass.name} does not have a #{fk} foreign key.") unless klass.column_names.include?(fk.to_s)
                end
              end

              true
            rescue Exception => e
              false
            end
          end

          def description
            "belong to #{@associations.to_sentence}"
          end

          def failure_message
            @failure_message || "expected #{@klass.name} to belong to #{@associations.to_sentence}, but it didn't"
          end

          def negative_failure_message
            "expected #{@klass.name} not to belong to #{@associations.to_sentence}, but it did"
          end
        end

        # Ensure that the belongs_to relationship exists.
        #
        #   it { should belong_to(:parent) }
        #
        def belong_to(*associations)
          Remarkable::ActiveRecord::Syntax::RSpec::BelongTo.new(*associations)
        end
      end

      module Shoulda
        # Ensure that the belongs_to relationship exists.
        #
        #   should_belong_to :parent
        #
        def should_belong_to(*associations)
          get_options!(associations)
          klass = model_class
          associations.each do |association|
            it "should belong to #{association}" do
              reflection = klass.reflect_on_association(association)
              fail_with("#{klass.name} does not have any relationship to #{association}") unless reflection
              reflection.macro.should == :belongs_to

              unless reflection.options[:polymorphic]
                associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize
                fk = reflection.options[:foreign_key] || reflection.primary_key_name
                fail_with("#{klass.name} does not have a #{fk} foreign key.") unless klass.column_names.include?(fk.to_s)
              end
            end
          end
        end
      end

    end 
  end
end
