class BelongTo < Remarkable::ActiveRecord
  def initialize(*associations)
    get_options!(associations)
    @associations = associations
  end

  def matches?(klass)
    @klass = klass
    @associations.each do |association|
      reflection = klass.reflect_on_association(association)

      unless reflection && reflection.macro == :belongs_to
        @message = "#{klass.name} does not have any relationship to #{association}"
        return false
      end

      unless reflection.options[:polymorphic]
        associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize
        fk = reflection.options[:foreign_key] || reflection.primary_key_name

        unless klass.column_names.include?(fk.to_s)
          @message = "#{klass.name} does not have a #{fk} foreign key."
          return false
        end
      end
    end
  end

  def description
    "belong to #{@associations.to_sentence}"
  end

  def failure_message
    @message || "expected #{@klass} to belong to #{@associations.to_sentence}, but it didn't"
  end

  def negative_failure_message
    "expected #{@klass} not to belong to #{@associations.to_sentence}, but it did"
  end
end

# Ensure that the belongs_to relationship exists.
#
#   it { Post.should belong_to(:user) }
#
def belong_to(*associations)
  BelongTo.new(*associations)
end
