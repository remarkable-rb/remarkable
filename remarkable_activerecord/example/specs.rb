# How to execute:
#
#   ruby example/specs.rb -rspec_options locale
#
# Example
#
#   ruby example/specs.rb -fs pt-BR
#

# Get given locale
locale = ARGV.pop

# Load spec helper
require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')

# Configure remarkable locale
Remarkable.add_locale File.join(File.dirname(__FILE__), "#{locale}.yml")
Remarkable.locale = locale

# Setting up a model
include ModelBuilder

define_model :user, :name => :string, :email => :string, :age => :integer do
  validates_presence_of :name, :email
  validates_length_of :name, :within => 3..40

  validates_uniqueness_of :email, :case_sensitive => false
  validates_numericality_of :age, :only_integer => true, :greather_than_or_equal_to => 18, :allow_blank => true
end

User.create!(:name => 'José', :email => 'jose.valim@gmail.com')

# Declaring tests
describe User do
  should_validate_presence_of :name, :email
  should_validate_length_of :name, :within => 3..40

  should_validate_uniqueness_of :email, :case_sensitive => false
  should_validate_numericality_of :age, :only_integer => true, :greather_than_or_equal_to => 18, :allow_blank => true
end



