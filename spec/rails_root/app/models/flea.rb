class Flea < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :dogs
end
