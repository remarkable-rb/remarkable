class HaveOne
  include Remarkable::Private

  def initialize(*associations)
    @associations = associations
  end

  def matches?(klass)
    @klass = klass
    @dependent = get_options!(@associations, :dependent)
    @associations.extract_options!
    
    @associations.each do |association|
      reflection = klass.reflect_on_association(association)

      unless reflection && reflection.macro == :has_one
        @message = "#{klass.name} does not have any relationship to #{association}"
        return false
      end

      associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize

      if reflection.options[:foreign_key]
        fk = reflection.options[:foreign_key]
      elsif reflection.options[:as]
        fk = reflection.options[:as].to_s.foreign_key
        fk_type = fk.gsub(/_id$/, '_type')

        unless associated_klass.column_names.include?(fk_type)
          @message = "#{associated_klass.name} does not have a #{fk_type} column."
          return false
        end
      else
        fk = klass.name.foreign_key
      end

      unless associated_klass.column_names.include?(fk.to_s)
        @message = "#{associated_klass.name} does not have a #{fk} foreign key."
        return false
      end

      if @dependent
        unless @dependent.to_s == reflection.options[:dependent].to_s
          @message = "#{association} should have #{@dependent} dependency"
          return false
        end
      end
    end
  end

  def description
    name = "have one #{@associations.to_sentence}"
    name += " dependent => #{@dependent}" if @dependent
    name
  end

  def failure_message
    @message || "expected #{@klass} to have one #{@associations.to_sentence}, but it didn't"
  end

  def negative_failure_message
    name = "expected #{@klass} not to have one #{@associations.to_sentence}"
    name += " dependent => #{@dependent}" if @dependent
    name += ", but it did"
    name
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
  HaveOne.new(*associations)
end
