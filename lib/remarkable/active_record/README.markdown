h1. ActiveRecord Macros

For each example below, we will show you the Rspec way and in the Macro (Shoulda) way. Choose the one that pleases you the most. :)

h2. Associations

h3. belong_to

Ensure that the belongs_to relationship exists.

<pre><code>  should_belong_to :parent
  it { should belong_to(:parent) }</code></pre>

h3. have_and_belong_to_many

Ensures that the has_and_belongs_to_many relationship exists, and that the join table is in place.

<pre><code>  should_have_and_belong_to_many :posts, :cars
  it{ should have_and_belong_to_many :posts, :cars }</code></pre>

h3. have_many

Ensures that the has_many relationship exists. Will also test that the associated table has the required columns. Works with polymorphic associations.

Options:
* :through - association name for has_many :through
* :dependent - tests that the association makes use of the dependent option.

<pre><code>  should_have_many :friends
  should_have_many :enemies, :through => :friends
  should_have_many :enemies, :dependent => :destroy

  it{ should have_many(:friends) }
  it{ should have_many(:enemies, :through => :friends) }
  it{ should have_many(:enemies, :dependent => :destroy) }</code></pre>

h3. have_one

Ensure that the has_one relationship exists. Will also test that the associated table has the required columns. Works with polymorphic associations.

Options:
* :dependent - tests that the association makes use of the dependent option.

<pre><code>  should_have_one :god
  it { should have_one(:god) }</code></pre>

h2. Database

h3. have_db_column

Ensure that the given column is defined on the models backing SQL table. The options are the same as the instance variables defined on the column definition: :precision, :limit, :default, :null, :primary, :type, :scale, and :sql_type.

<pre><code>  should_have_db_column :email, :type => "string", :default  => nil, :precision => nil, :limit => 255,
                        :null => true, :primary => false, :scale => nil, :sql_type => 'varchar(255)'

  it { should have_db_column(:email, :type => "string", :default  => nil, :precision => nil, :limit => 255,
                             :null => true, :primary => false, :scale => nil, :sql_type => 'varchar(255)') }</code></pre>

h3. have_db_columns

Ensure that the given columns are defined on the models backing SQL table.

<pre><code>  should_have_db_columns :id, :email, :name, :created_at
  it { should have_db_columns :id, :email, :name, :created_at }</code></pre>

h3. have_indices

Ensures that there are DB indices on the given columns or tuples of columns. Also aliased to @should_have_index@ for readability.

<pre><code>  should_have_indices :email, :name, [:commentable_type, :commentable_id]
  should_have_index :age

  it { should have_indices(:email, :name, [:commentable_type, :commentable_id]) }
  it { should have_index(:age) }</code></pre>

h3. have_index

Alias for @should_have_indices@.

h2. Validations

A word about validations: we currently cover *ALL* Active Record validations with *ALL* options. This is great, but you have to know a few things about it.

The first thing is that we only validate what you explicitly give. In other words, if you do:

  should_validate_numericality_of :age

It will only test if it allows only numbers for age. On Active Record, such validation implicitly states that :only_integer is false and :allow_nil is false, but those options are not tested by default. On Remarkable you have to explicitly give them in order to be tested:

  should_validate_numericality_of :age, :only_integer => false, :allow_nil => false

Why? Because tests are part of your software specification, it should not have defaults. You must declare it in order to understand what it does or not. The only default value that is adopted is the :message and we will explain why next.

The second thing is understand how @validate@ macros work:

  should_validate_inclusion_of :gender, %w(m f)

In this case, it will set a non valid value in age and search for the :inclusion message ("not included in list") in the error messages. If the message exists, your validation is working, otherwise, it's not. The thing is, if you change your error message, it will not be able to found the message and the test will always pass.

This is valid for all rspec matchers and not only Remarkable. Actually, we are the only one that fully supports I18n error messages. In other words, if you change the error message in through the I18n YAML files, everything will work properly. But when you set the message in your model like this:

  validates_inclusion_of :gender, %w(m f), :message => "woah?! what are you then?"

You have also to change the message in your tests.

  should_validate_inclusion_of :gender, %w(m f), :message => "woah?! what are you then?"

The third is, in any macro, if an instance variable has been created named after the model being tested, then the macro will use it to test. Otherwise, it will create a new instance to test against.

Deal? Now we are good to go!

h3. allow_mass_assignment_of

Ensures that the attribute can be set on mass update.

  should_allow_mass_assignment_of :email, :name
  it { should allow_mass_assignment_of(:email, :name) }

h3. have_named_scope

Ensures that the model has a method named scope_name that returns a NamedScope object with the proxy options set to the options you supply. scope_name can be either a symbol, or a method call which will be evaled against the model. The eval‘d method call has access to all the same instance variables that a should statement would.

Options: Any of the options that the named scope would pass on to find.

Example:

  should_have_named_scope :visible, :conditions => {:visible => true}

Passes for:

  named_scope :visible, :conditions => {:visible => true}

Or for:

  def self.visible
    scoped(:conditions => {:visible => true})
  end

You can test lambdas or methods that return ActiveRecord#scoped calls:

  should_have_named_scope 'recent(5)', :limit => 5
  should_have_named_scope 'recent(1)', :limit => 1

Passes for:

  named_scope :recent, lambda {|c| {:limit => c}}

Or for:

  def self.recent(c)
    scoped(:limit => c)
  end

h3. have_readonly_attributes

Ensures that the attribute cannot be changed once the record has been created.

  should_have_readonly_attributes :password, :admin_flag

h3. validate_acceptance_of

Ensures that the model cannot be saved if one of the attributes listed is not accepted.

Options:
* :accept - the expected value to be accepted.
* :allow_nil - when supplied, validates if it allows nil or not.
* :message - value the test expects to find in errors.on(:attribute).
  Regexp or symbol or string.  Default = I18n.translate('activerecord.errors.messages.accepted')

<pre><code>  should_validate_acceptance_of :eula, :terms
  should_validate_acceptance_of :eula, :terms, :accept => true

  it { should validate_acceptance_of(:eula, :terms) }
  it { should validate_acceptance_of(:eula, :terms, :accept => true) }</code></pre>

h3. validate_associated

Ensures that the model is invalid if one of the associations given is invalid.

It tries to build an instance of the association by two ways. Let's suppose a user that has many projects and you want to validate it:

  it { should validate_associated(:projects) }

The first attempt to build the association would be:

 @user.projects.build

If not possible, then we try:

 @user.build_project

Then it tries to save the associated object. If the object can be saved if success (in this case, it allows all attributes as blank), we won't be able to verify the validation and then an error will be raised. In such cases, you should instantiate the association before calling the matcher:

 it do
   @user = User.new
   @project = @user.projects.build
   should validate_associated(:projects)
 end

Or give :builder as option:

  should_validate_associated(:projects, :builder => proc { |user| user.projects.build }) }

Options:
* :builder - a proc to build the association.
* :message - value the test expects to find in errors.on(:attribute). Regexp or string.  Default = I18n.translate('activerecord.errors.messages.invalid')

<pre><code>  should_validate_associated :projects, :account
  should_validate_associated :projects, :builder => proc { |user| user.projects.build }

  it { should validate_associated(:projects, :account) }
  it { should validate_associated(:projects, :builder => proc { |user| user.projects.build }) }</code></pre>

h3. validate_confirmation_of

Ensures that the model cannot be saved if one of the attributes is not confirmed.

Options:
* :message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.confirmation')

  should_validate_confirmation_of :email, :password
  it { should validate_confirmation_of(:email, :password) }

h3. validate_exclusion_of

Ensures that given values are not valid for the attribute. If a range is given, ensures that the attribute is not valid in the given range.

Note: this matcher accepts at once just one attribute to test.

Options:
* :allow_nil - when supplied, validates if it allows nil or not.
* :allow_blank - when supplied, validates if it allows blank or not.
* :message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.exclusion')

<pre><code>  should_validate_exclusion_of :age, 30..60
  should_validate_exclusion_of :username, "admin", "user"
  should_not validate_exclusion_of :username, "clark_kent", "peter_park"

  it { should validate_exclusion_of(:age, 30..60) }
  it { should validate_exclusion_of(:username, "admin", "user") }
  it { should_not validate_exclusion_of(:username, "clark_kent", "peter_park") }</code></pre>

h3. validate_format_of

Ensures that the attribute can be set to the given values.

Note: this matcher accepts at once just one attribute to test.
Note: this matcher is also aliased as "allow_values_for"

Options:
* :allow_nil - when supplied, validates if it allows nil or not.
* :allow_blank - when supplied, validates if it allows blank or not.
* :message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.invalid')

<pre><code>  should validate_format_of :isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0"
  should_not validate_format_of :isbn, "bad 1", "bad 2"

  it { should validate_format_of(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }
  it { should_not validate_format_of(:isbn, "bad 1", "bad 2") }
</code></pre>

h3. validate_inclusion_of

Ensures that given values are valid for the attribute. If a range is given, ensures that the attribute is valid in the given range.

Note: this matcher accepts at once just one attribute to test.

Options:
* :allow_nil - when supplied, validates if it allows nil or not.
* :allow_blank - when supplied, validates if it allows blank or not.
* :message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.inclusion')

<pre><code>
  it { should validate_inclusion_of(:age, 18..100) }
  it { should validate_inclusion_of(:isbn, "isbn 1 2345 6789 0", "ISBN 1-2345-6789-0") }

  it { should_not validate_inclusion_of(:isbn, "bad 1", "bad 2") }
</code></pre>

h3. validate_length_of

Validates the length of the given attributes. You have also to supply one of the following options: minimum, maximum, is or within.

Note: this method is also aliased as @validate_size_of@.

Options:
* :minimum - The minimum size of the attribute.
* :maximum - The maximum size of the attribute.
* :is - The exact size of the attribute.
* :within - A range specifying the minimum and maximum size of the attribute.
* :in - A synonym(or alias) for :within.
* :allow_nil - when supplied, validates if it allows nil or not.
* :allow_blank - when supplied, validates if it allows blank or not.
* :short_message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.too_short') % range.first
* :long_message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.too_long') % range.last
* :message - value the test expects to find in errors.on(:attribute) only when :minimum, :maximum or :is is given.
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.wrong_length') % value

<pre><code>  should_validate_length_of :password, :within => 6..20
  should_validate_length_of(:password, :maximum => 20
  should_validate_length_of(:password, :minimum => 6
  should_validate_length_of(:age, :is => 18

  it { should validate_length_of(:password, :within => 6..20) }
  it { should validate_length_of(:password, :maximum => 20) }
  it { should validate_length_of(:password).minimum(6) }
  it { should validate_length_of(:age).is(18) }</code></pre>

h3. validate_numericality_of

Ensures that the given attributes accepts only numbers.

Options:

* :only_integer - when supplied, checks if it accepts only integers or not
* :odd - when supplied, checks if it accepts only odd values or not
* :even - when supplied, checks if it accepts only even values or not
* :equal_to - when supplied, checks if attributes are only valid when equal to given value
* :less_than - when supplied, checks if attributes are only valid when less than given value
* :greater_than - when supplied, checks if attributes are only valid when greater than given value
* :less_than_or_equal_to - when supplied, checks if attributes are only valid when less than or equal to given value
* :greater_than_or_equal_to - when supplied, checks if attributes are only valid when greater than or equal to given value
* :message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.not_a_number')

<pre><code>  should_validate_numericality_of :age, :price
  should_validate_numericality_of :age, :odd => true
  should_validate_numericality_of :age, :even => true
  should_validate_numericality_of :age, :only_integer => true

  it { should validate_numericality_of(:age, :price) }
  it { should validate_numericality_of(:age).odd }
  it { should validate_numericality_of(:age, :even => true) }
  it { should validate_numericality_of(:age).only_integer }</code></pre>

h3. validate_presence_of

Ensures that the model cannot be saved if one of the attributes listed is not present.

Options:
* :message - value the test expects to find in errors.on(:attribute).
  Regexp, string or symbol. Default = I18n.translate('activerecord.errors.messages.blank')

 should_validate_presence_of(:name, :phone_number)
 it { should validate_presence_of(:name, :phone_number) }

h3. validate_uniqueness_of

Ensures that the model cannot be saved if one of the attributes listed is not unique.

Requires an existing record in the database. If you supply :allow_nil as option, you need to have in the database a record with the given attribute nil and another with the given attribute not nil. The same is required for allow_blank option.

Options:
* :scope - field(s) to scope the uniqueness to.
* :case_sensitive - the matcher look for an exact match.
* :allow_nil - when supplied, validates if it allows nil or not.
* :allow_blank - when supplied, validates if it allows blank or not.
* :message - value the test expects to find in errors.on(:attribute).
 Regexp, string or symbol.  Default = I18n.translate('activerecord.errors.messages.taken')

<pre><code>
  should_validate_uniqueness_of :keyword, :username
  should_validate_uniqueness_of :name, :message => "O NOES! SOMEONE STOELED YER NAME!"
  should_validate_uniqueness_of :email, :scope => :name, :case_sensitive => false
  should_validate_uniqueness_of :address, :scope => [:first_name, :last_name]

  it { should validate_uniqueness_of(:keyword, :username) }
  it { should validate_uniqueness_of(:name, :message => "O NOES! SOMEONE STOELED YER NAME!") }
  it { should validate_uniqueness_of(:email, :scope => :name, :case_sensitive => false) }
  it { should validate_uniqueness_of(:address, :scope => [:first_name, :last_name]) }
</pre></code>

