# Create a proc that will define Remarkable ActiveRecord, Sequel and Datamapper
# to avoid their respective gem to be loaded in tests. We cannot do this inside
# the rails_load! method because we cannot define modules inside methods.
#
STUB_ORM = proc {
  module Remarkable
    module ActiveRecord; end
    module Datamapper; end
    module Sequel; end
  end
}

RAILS_ROOT = File.dirname(__FILE__) + '/rails_root'

def rails_load!
  require "#{RAILS_ROOT}/config/environment.rb"

  # Load Remarkable core on place to avoid gem to be loaded
  require File.join(File.dirname(__FILE__), '..', '..', 'remarkable', 'lib', 'remarkable')

  # Execute block if given
  yield if block_given?

  # Define ORMs
  STUB_ORM.call

  # Load Remarkable Rails
  require File.join(File.dirname(__FILE__), '..', 'lib', 'remarkable_rails')

  ActiveRecord::Migration.verbose = false
  ActiveRecord::Migrator.migrate("#{RAILS_ROOT}/db/migrate")

  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = false
    config.use_instantiated_fixtures  = false
    config.fixture_path = FIXTURE_PATH
  end
end
