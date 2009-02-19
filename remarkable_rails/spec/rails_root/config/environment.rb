# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_ENV = ENV['RAILS_ENV'] = 'test'

RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.log_level                     = :debug
  config.cache_classes                 = false
  config.whiny_nils                    = true
  config.action_mailer.delivery_method = :test
end

# Dependencies.log_activity = true
