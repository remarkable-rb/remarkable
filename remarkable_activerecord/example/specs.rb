# How to execute:
#
#   ruby example/specs.rb -rspec_options locale
#
# Examples
#
#   ruby example/specs.rb -fs pt-BR
#   ruby example/specs.rb -fs en
#
# You need rspec >= 1.2.0, activerecord >= 2.1.2 and sqlite3.

# Get given locale
locale = ARGV.pop

# Load rubygems and rspec
require 'rubygems'
require 'spec'

# Load spec helper
require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')

# Configure remarkable locale
locale_file = File.join(File.dirname(__FILE__), "#{locale}.yml")
Remarkable.add_locale locale_file if File.exist?(locale_file)
Remarkable.locale = locale

# Setting up a model
include ModelBuilder

define_model :user, :name => :string, :email => :string, :age => :integer do
  validates_presence_of :name, :email
  validates_length_of :name, :within => 3..40

  validates_uniqueness_of :email, :case_sensitive => false
  validates_numericality_of :age, :only_integer => true, :greather_than_or_equal_to => 18, :allow_blank => true
end

# Create at least one model in the database
User.create!(:name => 'José', :email => 'jose.valim@gmail.com')

# Declaring specs
describe User do
  xshould_validate_presence_of :age

  should_validate_presence_of :name, :email
  should_validate_length_of :name, :within => 3..40

  should_validate_uniqueness_of :email, :case_sensitive => false
  should_validate_numericality_of :age, :only_integer => true, :greather_than_or_equal_to => 18, :allow_blank => true
end

# Run specs
exit ::Spec::Runner::CommandLine.run
