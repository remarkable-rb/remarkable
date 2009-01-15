require 'remarkable/active_record/helpers'
%w( database associations validations callbacks ).each do |folder|
  Dir[File.join(File.dirname(__FILE__), "macros", folder, '*.rb')].each do |file|
    require file
  end
end
require 'remarkable/active_record/macros'

module Spec
  module Rails
    module Example
      class ModelExampleGroup
        include Remarkable::Assertions
        include Remarkable::ActiveRecord::Matchers
        extend Remarkable::ActiveRecord::Macros

        private
        include Remarkable::Private
      end
    end
  end
end
