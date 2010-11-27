# Remarkable #

http://remarkable.rubyforge.org/

## Description ##

Remarkable is a framework for rspec matchers that supports macros and I18n. It's
constituted of three pieces:

* Remarkable: the framework with helpers, DSL, I18n and rspec features;

* Remarkable ActiveModel: a collection of matchers for ActiveModel compliant models. It 
  currently supports all ActiveModel validations. Future plan include testing for
  ActiveModel API compliance and ActiveModel serialization.

* Remarkable ActiveRecord: a collection of matchers for ActiveRecord. It
  supports all ActiveRecord validations, associations and some extra matchers.

* Remarkable Rails: a collection of matchers for ActionController. It also
  includes MacroStubs, which is a clean DSL for stubbing your controller methods.

  NOTE: Remarkable Rails is currently not available for version 4.0.0.alpha1
  We are thinking of breaking this up into Remarkable Rack, and Remarkable ActionController
  gems, along the lines of splitting off ActiveModel macros.

In each folder above, you can find a README more detailed description of each piece.

## Why use Remarkable for Rails? ##

* The only one with matchers for all ActiveRecord validations, with support to
  all options (except `:on` and the option `:with` in `validates_format_of`);

* Matchers for all ActiveRecord associations. The only one which supports all
  these options:

    `:through, :source, :source_type, :class_name, :foreign_key, :dependent,
    :join_table, :uniq, :readonly, :validate, :autosave, :counter_cache, :polymorphic`

  Plus Arel scopes:

    `:select, :where, :include, :group, :having, :order, :limit, :offset`

  Besides in Remarkable 4.0 matchers became much smarter. Whenever `:join_table`
  or `:through` is given as option, it checks if the given table exists. Whenever
  `:foreign_key` or `:counter_cache` is given, it checks if the given column exists;

* ActionController matchers:

    `:assign_to`, `:filter_params`, `:redirect_to`, `:render_with_layout`, `:respond_with`, 
    `:render_template`, `:route`, `:set_session` and `:set_the_flash`;

* Macro stubs: make your controllers specs easier to main, more readable and DRY;

* Tests and more tests. We have a huge tests suite ready to run and tested in
  Rails 2.1.2, 2.2.2 and 2.3.2;

* I18n and great documentation.

* It has your style. You can choose between:

    1) `it { should validate_numericality_of(:age).greater_than(18).only_integer }`

    2) `it { should validate_numericality_of(:age, :greater_than => 18, :only_integer => true) } `

    3) `should_validate_numericality_of :age, :greater_than => 18, :only_integer => true`

    4) `should_validate_numericality_of :age do |m|
         m.only_integer
         m.greater_than 18
         # Or: m.greater_than = 18
       end`

Remarkable Rails requires `rspec >= 2.0.0` and `rspec-rails >= 2.0.0.`

## Install on Rails ##

Install the gem:

    sudo gem install remarkable_rails

This will install `remarkable`, `remarkable_activerecord` and `remarkable_rails` gems.

Inside Rails you need to require just this gem. If you are using ActiveRecord,
it will automatically require the `remarkable_activerecord` gem.

## Rails 3 ##

In Rails 3, in order to rspec load properly, you have to use this configuration
on your Gemfile

    gem "rspec"
    gem "rspec-rails"
    gem "remarkable_activerecord"

NOTE: `remarkable_rails` is currently not supported. 

Add the require after the `rspec/rails` line in your `spec_helpers.rb`. Although `RSpec2` convention
encourages you to use `spec/support/`, if you have Remarkable matchers in there, you will want
to load that after you load Remarkable

    require 'rspec/rails'
    require 'remarkable/active_record'

Alternatively, if you are using an ActiveModel-compliant gem, such as the newer Mongo and
CouchDB gems, you can use:

    require 'remarkable/active_model'

and have access to all ActiveModel matchers. Note that loading `remarkable/active_record` will
automatically load `remarkable/active_model`

This is the safest way to avoid conflicts.

Please note, due to the massive refactoring in Rails 3 and RSpec 2, we are not supporting
backwards compatibility with Rails 2 or RSpec 1. You will need to use the Remarkable 3.x series
if you are still using Rails 2.

## How to setup your machine to contribute with remarkable? ##

    gem install bundler
    bundle install
    rake # red, green, refactor

## Developers ##

If you are developing matchers, for example `hpricot` matchers, you need to install
only the remarkable "core" gem:

    sudo gem install remarkable

If you stumble into any problem or have doubts while building your matchers,
please drop us a line. We are currently searching for people who wants to join
us and provide matchers for Datamapper, Sequel, Sinatra and all other possible
options. :)

## Browse the documentation ##

* Remarkable: 
  * http://remarkable.rubyforge.org/core/

* Remarkable ActiveRecord:
  * http://remarkable.rubyforge.org/activerecord/
  * http://remarkable.rubyforge.org/activerecord/classes/Remarkable/ActiveRecord/Matchers.html

* Remarkable Rails:
  * http://remarkable.rubyforge.org/rails/
  *  http://remarkable.rubyforge.org/rails/classes/Remarkable/ActionController/Matchers.html

## More information ##

* Google group: 
  * http://groups.google.com/group/remarkable-core
* Bug tracking: 
  * http://github.com/remarkable/remarkable/issues

## Contributors ##

http://github.com/remarkable/remarkable/contributors

## LICENSE ##

All projects are under MIT LICENSE.

