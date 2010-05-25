# Load core files
require 'remarkable/core/version'
require 'remarkable/core/matchers'
require 'remarkable/core/macros'
require 'remarkable/core/i18n'
require 'remarkable/core/dsl'
require 'remarkable/core/messages'
require 'remarkable/core/base'
require 'remarkable/core/negative'
require 'remarkable/core/core_ext/array'
require 'remarkable/core/rspec' 

# Add default locale
dir = File.dirname(__FILE__)
Dir["#{dir}/../../locale/*yml"].each {|f| Remarkable.add_locale(f) }
