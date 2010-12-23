# encoding: utf-8
require 'rspec'
require 'active_support'
require 'active_record'

require File.expand_path('path_helpers', File.join(File.dirname(__FILE__), '/../../'))
load_project_path :remarkable, :remarkable_activemodel, :remarkable_activerecord

require 'remarkable/active_record'

# Configure ActiveRecord connection
ActiveRecord::Base.establish_connection(
  :adapter  => 'sqlite3',
  :database => ':memory:'
)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |c|
  c.around do |example|
    if example.metadata.has_key?(:broken)
      # TODO use the pending block form when RSpec supports it so we now when an example is fixed
      pending "is broken since change from 3.0.0.beta4 to 3.0.3"# do
      #         example.run
      #       end
    else
      example.call
    end
  end
end