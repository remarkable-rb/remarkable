# Load core files
require 'remarkable/version'
require 'remarkable/matchers'
require 'remarkable/macros'
require 'remarkable/i18n'
require 'remarkable/dsl'
require 'remarkable/messages'
require 'remarkable/base'
require 'remarkable/negative'
require 'remarkable/core_ext/array'
require 'remarkable/rspec' 

dir = File.dirname(__FILE__)
Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')
