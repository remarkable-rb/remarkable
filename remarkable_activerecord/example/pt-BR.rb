require File.join(File.dirname(__FILE__), '..', 'spec', 'spec_helper')
require File.join(File.dirname(__FILE__), 'models')

Remarkable.add_locale File.join(File.dirname(__FILE__), 'pt-BR.yml')
Remarkable.locale = :"pt-BR"

describe User do
  should_validate_presence_of :name, :email
  should_validate_length_of :name, :within => 3..40

  should_validate_uniqueness_of :email, :case_sensitive => false
  should_validate_numericality_of :age, :only_integer => true, :greather_than_or_equal_to => 18, :allow_blank => true
end
