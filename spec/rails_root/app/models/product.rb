class Product < ActiveRecord::Base
  validates_presence_of :title

  validates_inclusion_of :price, :in => 0..99,    :unless => :tangible
  validates_exclusion_of :weight, :in => 10..100, :unless => :tangible
  validates_format_of :size, :with => /^\d+\D+$/, :unless => :tangible

  validates_presence_of :price,                        :if => :tangible
  validates_inclusion_of :price,  :in => 1..9999,      :if => :tangible, :allow_nil => true
  validates_inclusion_of :weight, :in => 1..100,       :if => :tangible, :allow_blank => true
  validates_inclusion_of :size,   :in => %w(S M L XL), :if => :tangible, :allow_blank => true
  validates_exclusion_of :size,   :in => %w(XS XM),    :if => :tangible
  validates_length_of :size, :in => 5..20,             :if => :tangible
end
