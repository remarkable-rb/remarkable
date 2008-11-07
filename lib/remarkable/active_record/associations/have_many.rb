module Remarkable
  class HaveMany < Remarkable::Association
    def initialize(*associations)
      @through, @dependent = get_options!(associations, :through, :dependent)
      @associations = associations
    end

    def matches?(klass)
      @klass = klass

      begin
        @associations.each do |association|
          reflection = klass.reflect_on_association(association)
          fail("#{klass.name} does not have any relationship to #{association}") unless reflection && reflection.macro == :has_many

          if @through
            through_reflection = klass.reflect_on_association(@through)
            fail("#{klass.name} does not have any relationship to #{@through}") unless through_reflection && @through == reflection.options[:through]
          end

          if @dependent
            fail("#{association} should have #{@dependent} dependency") unless @dependent.to_s == reflection.options[:dependent].to_s
          end

          # Check for the existence of the foreign key on the other table
          unless reflection.options[:through]
            if reflection.options[:foreign_key]
              fk = reflection.options[:foreign_key]
            elsif reflection.options[:as]
              fk = reflection.options[:as].to_s.foreign_key
            else
              fk = reflection.primary_key_name
            end

            associated_klass_name = (reflection.options[:class_name] || association.to_s.classify)
            associated_klass = associated_klass_name.constantize
            
            fail("#{associated_klass.name} does not have a #{fk} foreign key.") unless associated_klass.column_names.include?(fk.to_s)
          end
        end

        true
      rescue Exception => e
        false
      end
    end

    def description
      message = "have many #{@associations.to_sentence}"
      message += " through #{@through}" if @through
      message += " dependent => #{@dependent}" if @dependent
      message
    end

    def failure_message
      message = "expected #{@klass.name} to have many #{@associations.to_sentence}"
      message += " through #{@through}" if @through
      message += " dependent => #{@dependent}" if @dependent
      message += ", but it didn't"
      @failure_message || message
    end

    def negative_failure_message
      message = "expected #{@klass.name} not to have many #{@associations.to_sentence}"
      message += " through #{@through}" if @through
      message += " dependent => #{@dependent}" if @dependent
      message += ", but it did"
      message
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
#   it { User.should have_many(:friends) }
#   it { User.should have_many(:enemies, :through => :friends) }
#   it { User.should have_many(:friends, :dependent => :destroy) }
#
def have_many(*associations)
  Remarkable::HaveMany.new(*associations)
end
