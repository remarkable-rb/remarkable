require 'remarkable/active_record/helpers'
%w( database associations validations ).each do |folder|
  Dir[File.join(File.dirname(__FILE__), "macros", folder, '*.rb')].each do |file|
    require file
  end
end

module Spec
  module Rails
    module Example
      class ModelExampleGroup
        include Remarkable::Assertions
        include Remarkable::ActiveRecord::Matchers
        extend Remarkable::ActiveRecord::Macros
      end
    end
  end
end
