module Remarkable
  class HaveOne < Remarkable::Association
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
end

# Ensure that the has_one relationship exists.  Will also test that the
# associated table has the required columns.  Works with polymorphic
# associations.
#
# Options:
# * <tt>:dependent</tt> - tests that the association makes use of the dependent option.
#
# Example:
#   it { User.should have_one(:address) }
#
def have_one(*associations)
  Remarkable::HaveOne.new(*associations)
end
