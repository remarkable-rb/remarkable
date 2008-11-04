class HaveMany < Remarkable::ActiveRecord
  def initialize(*associations)
    @through, @dependent = get_options!(associations, :through, :dependent)
    @associations = associations
  end

  def matches?(klass)
    @klass = klass

    @associations.each do |association|
      @association = association

      reflection = klass.reflect_on_association(association)
      unless reflection && reflection.macro == :has_many
        @message = "#{klass.name} does not have any relationship to #{association}"
        return false
      end

      if @through
        through_reflection = klass.reflect_on_association(@through)
        unless through_reflection && @through == reflection.options[:through]
          @message = "#{klass.name} does not have any relationship to #{@through}"
          return false
        end
      end

      if @dependent
        unless @dependent.to_s == reflection.options[:dependent].to_s
          @message = "#{association} should have #{@dependent} dependency"
          return false
        end
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

        unless associated_klass.column_names.include?(fk.to_s)
          @message = "#{associated_klass.name} does not have a #{fk} foreign key."
          return false
        end
      end
    end

  end

  def description
    name = "have many #{@associations.to_sentence}"
    name += " through #{@through}" if @through
    name += " dependent => #{@dependent}" if @dependent
    name
  end

  def failure_message
    @message || "expected #{@klass} to have many #{@associations.to_sentence}, but it didn't"
  end

  def negative_failure_message
    name = "expected not to have many #{@associations.to_sentence}"
    name += " through #{@through}" if @through
    name += " dependent => #{@dependent}" if @dependent
    name += ", but it did"
    name
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
  HaveMany.new(*associations)
end
