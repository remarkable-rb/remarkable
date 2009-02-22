# When the matcher is one of the listed below, the subject is the controller
# response, so we have to register it for such matchers.
#
condition = proc do |matcher|
  [ 'Spec::Rails::Matchers::AssertSelect',
    'Spec::Rails::Matchers::HaveText',
    'Spec::Rails::Matchers::IncludeText',
    'Spec::Rails::Matchers::RedirectTo',
    'Spec::Rails::Matchers::RenderTemplate'
  ].include?(matcher.class.to_s)
end

Remarkable.register_subject(condition) do
  self.response if self.respond_to?(:response)
end
