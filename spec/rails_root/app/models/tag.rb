class Tag < ActiveRecord::Base
  has_many :taggings, :dependent => :destroy
  has_many :posts, :through => :taggings

  validates_length_of :name, :minimum => 1, :allow_blank => true
  validates_presence_of :name

  attr_accessible :name
end
