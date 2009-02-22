class Address < ActiveRecord::Base
  # belongs_to :addressable, :polymorphic => true

  validates_length_of :zip, :minimum => 5, :allow_nil => true
  validates_uniqueness_of :title, :scope => [:addressable_type, :addressable_id]
  validates_numericality_of :zip, :less_than => 20, :greater_than => 10
end
