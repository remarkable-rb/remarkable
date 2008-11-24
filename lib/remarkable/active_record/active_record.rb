require 'remarkable/active_record/helpers'
module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Macros      
      private
      include Remarkable::Private
    end
  end
end

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
