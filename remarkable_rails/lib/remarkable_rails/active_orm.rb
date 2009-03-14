# This will responsable to check which ORM is loaded and include respective
# matchers.
#
if defined?(ActiveRecord::Base)
  unless Remarkable.const_defined?('ActiveRecord')
    begin
      require 'remarkable_activerecord'
    rescue LoadError
      require 'rubygems'
      gem 'remarkable_activerecord'
      require 'remarkable_activerecord'
    end
  end

  # Include Remarkable ActiveRecord matcher in appropriate ExampleGroup
  if defined?(Spec::Rails)
    Remarkable.include_matchers!(Remarkable::ActiveRecord, Spec::Rails::Example::ModelExampleGroup)
  end
end
