class HaveOne
  include Remarkable::Private
  
  def initialize(*associations)
    @associations = associations
  end

  def matches?(klass)
    @klass = klass

    dependent = get_options!(@associations, :dependent)
    # klass = model_class
    @associations.each do |association|
      name = "have one #{association}"
      name += " dependent => #{dependent}" if dependent
      
      describe klass do
        it name do
          reflection = klass.reflect_on_association(association)
          reflection.should_not be_nil
          # assert reflection, "#{klass.name} does not have any relationship to #{association}"
          assert_equal :has_one, reflection.macro

          associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize

          if reflection.options[:foreign_key]
            fk = reflection.options[:foreign_key]
          elsif reflection.options[:as]
            fk = reflection.options[:as].to_s.foreign_key
            fk_type = fk.gsub(/_id$/, '_type')
            assert associated_klass.column_names.include?(fk_type),
            "#{associated_klass.name} does not have a #{fk_type} column."
          else
            fk = klass.name.foreign_key
          end
          assert associated_klass.column_names.include?(fk.to_s),
          "#{associated_klass.name} does not have a #{fk} foreign key."

          if dependent
            assert_equal dependent.to_s,
            reflection.options[:dependent].to_s,
            "#{association} should have #{dependent} dependency"
          end 
        end
      end
    end
  end

  def failure_message
    "expected #{@klass.inspect} to have_one #{@associations.inspect}, but it didn't"
  end

  def negative_failure_message
    "expected #{@klass.inspect} not to have_one #{@associations.inspect}, but it did"
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
def have_one(*associations)
  HaveOne.new(*associations)
end
