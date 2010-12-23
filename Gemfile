source :gemcutter

gemspec

group :development do
  gem 'rake', '0.8.7'
  gem 'jeweler', '1.4.0'
  gem 'sqlite3-ruby', '1.2.5'
end

rspec_version = File.read(File.expand_path("../RSPEC_VERSION",__FILE__)).strip

group :test do
  gem 'rspec',              rspec_version
  gem 'rspec-core',         rspec_version
  gem 'rspec-expectations', rspec_version
  gem 'rspec-mocks',        rspec_version
  gem 'rspec-rails',        rspec_version
end
