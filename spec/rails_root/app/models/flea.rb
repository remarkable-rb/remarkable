class Flea < ActiveRecord::Base
  has_and_belongs_to_many :dogs
  validates_presence_of :name
  validates_uniqueness_of :name, :case_sensitive => false
end
