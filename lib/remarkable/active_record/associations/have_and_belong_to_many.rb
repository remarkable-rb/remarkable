module Remarkable
  class HaveAndBelongToMany < Remarkable::Association
    def initialize(*associations)
      get_options!(associations)
      @associations = associations
    end

    def matches?(klass)
      @klass = klass

      @associations.each do |association|
        reflection = klass.reflect_on_association(association)      
        unless reflection && reflection.macro == :has_and_belongs_to_many
          @message = "#{klass.name} does not have any relationship to #{association}"
          return false
        end

        table = reflection.options[:join_table]
        unless ::ActiveRecord::Base.connection.tables.include?(table.to_s)
          @message = "table #{table} doesn't exist"
          return false
        end
      end
    end

    def description
      "should have and belong to many #{@associations.to_sentence}"
    end

    def failure_message
      @message || "expected #{@klass} to have and belong to many #{@associations.to_sentence}, but it didn't"
    end

    def negative_failure_message
      "expected should not to have and belong to many #{@associations.to_sentence}, but it did"
    end
  end
end

# Ensures that the has_and_belongs_to_many relationship exists, and that the join
# table is in place.
#
#   it { User.should have_and_belong_to_many(:posts, :cars) }
#
def have_and_belong_to_many(*associations)
  Remarkable::HaveAndBelongToMany.new(*associations)
end
