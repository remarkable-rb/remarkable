module Pets
  class Dog < ActiveRecord::Base
    # belongs_to :user, :foreign_key => :owner_id
    # belongs_to :address
    # has_and_belongs_to_many :fleas, :join_table => :fleas

    validates_numericality_of :age, :greater_than => 1, :less_than => 20,
                              :only_integer => true, :allow_nil => true

    validates_presence_of :owner_id
  end
end
