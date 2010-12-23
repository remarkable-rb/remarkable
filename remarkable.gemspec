version = File.read(File.expand_path("../REMARKABLE_VERSION",__FILE__)).strip

version

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'remarkable'
  s.version     = version
  s.description = 'Remarkable: a framework for rspec matchers and macros, with support for I18n.'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.3.6"

  s.authors = ["Ho-Sheng Hsiao", "Carlos Brando", "Jos\303\251 Valim"]
  s.date = '2010-12-23'
  s.description = 'Remarkable: a framework for rspec matchers and macros, with support for I18n.'
  s.email = ["hosh@sparkfly.com", "eduardobrando@gmail.com", "jose.valim@gmail.com"]

  s.add_dependency('remarkable_core',         version)
  s.add_dependency('remarkable_activemodel',  version)
  s.add_dependency('remarkable_activerecord', version)

  # TODO Add the following later
  # s.add_dependency('remarkable_rails',        version)
  # TODO find a place for the following
  # s.add_dependency('remarkable_datamapper',   version)
end
