class Tagging < ActiveRecord::Base
  belongs_to :post
  belongs_to :tag

  validates_associated :post, :tag
end
