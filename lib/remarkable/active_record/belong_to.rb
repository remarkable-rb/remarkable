class BelongTo
  def initialize(*associations)
    associations.extract_options!
    @associations = associations
  end

  def matches?(klass)
    @klass = klass

    @associations.each do |association|
      describe klass do
        it "should belong to #{association}" do
          reflection = klass.reflect_on_association(association)
          reflection.should_not be_nil
          reflection.macro.should eql(:belongs_to)

          unless reflection.options[:polymorphic]
            associated_klass = (reflection.options[:class_name] || association.to_s.camelize).constantize
            fk = reflection.options[:foreign_key] || reflection.primary_key_name
            klass.column_names.include?(fk.to_s).should be_true
          end
        end        
      end      
    end
  end

  def failure_message
    "expected #{@klass.inspect} to belong_to #{@associations.inspect}, but it didn't"
  end

  def negative_failure_message
    "expected #{@klass.inspect} not to belong_to #{@associations.inspect}, but it did"
  end
end

def belong_to(*associations)
  BelongTo.new(*associations)
end