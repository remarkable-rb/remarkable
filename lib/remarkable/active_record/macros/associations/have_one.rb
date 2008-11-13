module Remarkable
  module Syntax

    module RSpec
      class HaveOne
        include Remarkable::Private
        
        def initialize(*associations)
          @dependent = get_options!(associations, :dependent)
          @associations = associations
        end

        def matches?(klass)
          @klass = klass

          begin
            @associations.each do |association|
              reflection = klass.reflect_on_association(association)
              fail("#{klass.name} does not have any relationship to #{association}") unless reflection && reflection.macro == :has_one

              associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize

              if reflection.options[:foreign_key]
                fk = reflection.options[:foreign_key]
              elsif reflection.options[:as]
                fk = reflection.options[:as].to_s.foreign_key
                fk_type = fk.gsub(/_id$/, '_type')

                fail("#{associated_klass.name} does not have a #{fk_type} column.") unless associated_klass.column_names.include?(fk_type)
              else
                fk = klass.name.foreign_key
              end

              fail("#{associated_klass.name} does not have a #{fk} foreign key.") unless associated_klass.column_names.include?(fk.to_s)

              if @dependent
                fail("#{association} should have #{@dependent} dependency") unless @dependent.to_s == reflection.options[:dependent].to_s
              end
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          message = "have one #{@associations.to_sentence}"
          message += " dependent => #{@dependent}" if @dependent
          message
        end

        def failure_message
          message = "expected #{@klass.name} to have one #{@associations.to_sentence}"
          message += " dependent => #{@dependent}" if @dependent      
          message += ", but it didn't"      
          @failure_message || message
        end

        def negative_failure_message
          message = "expected #{@klass.name} not to have one #{@associations.to_sentence}"
          message += " dependent => #{@dependent}" if @dependent
          message += ", but it did"
          message
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
      #   it { should have_one(:god) } # unless hindu
      #
      def have_one(*associations)
        Remarkable::Syntax::RSpec::HaveOne.new(*associations)
      end
    end

    module Shoulda
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
          name = "should have one #{association}"
          name += " dependent => #{dependent}" if dependent
          it name do
            reflection = klass.reflect_on_association(association)
            fail_with("#{klass.name} does not have any relationship to #{association}") unless reflection
            reflection.macro.should == :has_one

            associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize

            if reflection.options[:foreign_key]
              fk = reflection.options[:foreign_key]
            elsif reflection.options[:as]
              fk = reflection.options[:as].to_s.foreign_key
              fk_type = fk.gsub(/_id$/, '_type')
              unless associated_klass.column_names.include?(fk_type)
                fail_with "#{associated_klass.name} does not have a #{fk_type} column."
              end
            else
              fk = klass.name.foreign_key
            end
            unless associated_klass.column_names.include?(fk.to_s)
              fail_with "#{associated_klass.name} does not have a #{fk} foreign key."
            end

            if dependent
              unless reflection.options[:dependent].to_s == dependent.to_s
                fail_with "#{association} should have #{dependent} dependency"
              end
            end
          end
        end
      end
    end

  end
end
