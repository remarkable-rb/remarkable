# Add new inflection rules to avoid those rules from being overwriten.
if defined?(ActiveSupport::Inflector)
  ActiveSupport::Inflector.inflections do |inflect|
    inflect.irregular 'attribute', 'attributes'
    inflect.irregular 'good_value', 'good_values'
  end
end
