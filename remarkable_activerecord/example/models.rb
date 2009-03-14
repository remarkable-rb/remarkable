include ModelBuilder

define_model :user, :name => :string, :email => :string, :age => :integer do
  validates_presence_of :name, :email
  validates_length_of :name, :within => 3..40

  validates_uniqueness_of :email, :case_sensitive => false
  validates_numericality_of :age, :only_integer => true, :greather_than_or_equal_to => 18, :allow_blank => true
end

User.create!(:name => 'José', :email => 'jose.valim@gmail.com')
