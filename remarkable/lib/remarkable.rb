# Load core files
dir = File.dirname(__FILE__)
require File.join(dir, 'remarkable', 'version')
require File.join(dir, 'remarkable', 'matchers')
require File.join(dir, 'remarkable', 'i18n')
require File.join(dir, 'remarkable', 'dsl')
require File.join(dir, 'remarkable', 'messages')

require File.join(dir, 'remarkable', 'base')
require File.join(dir, 'remarkable', 'macros')
require File.join(dir, 'remarkable', 'pending')
require File.join(dir, 'remarkable', 'negative')
require File.join(dir, 'remarkable', 'core_ext', 'array')

if defined?(Spec)
  require File.join(dir, 'remarkable', 'rspec')
end

Remarkable.add_locale File.join(dir, '..', 'locale', 'en.yml')
