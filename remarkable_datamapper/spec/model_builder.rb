# This is based on Shoulda model builder for Test::Unit.
#

# TODO: !!! These functions are not all updated yet
module ModelBuilder
  def self.included(base)
    return unless base.name =~ /^Spec/

    base.class_eval do
      after(:each) do
        if @defined_constants
          @defined_constants.each do |class_name| 
            Object.send(:remove_const, class_name)
          end
        end

        if @created_tables
          @created_tables.each do |table_name|
            DataMapper::Repository.adapters[:default].execute("DROP TABLE IF EXISTS #{table_name}")
          end
        end
      end
    end

    base.extend ClassMethods
  end

  def create_table(model)
    adapter = DataMapper::Repository.adapters[:default]
    table_name = model.to_s.tableize
    command = "DROP TABLE IF EXISTS #{table_name}"

    begin
      adapter.execute(command)
      adapter.create_model_storage(model)
      @created_tables ||= []
      @created_tables << table_name
      adapter
    rescue Exception => e
      adapter.execute(command)
      raise e
    end
  end

  def define_constant(class_name, base, &block)
    class_name = class_name.to_s.camelize

    klass = Class.new
    klass.send :include, base
    Object.const_set(class_name, klass) #unless klass

    klass.class_eval(&block) if block_given?

    @defined_constants ||= []
    @defined_constants << class_name

    klass
  end

  def define_model_class(class_name, &block)
    define_constant(class_name, DataMapper::Resource, &block)
  end

  def define_model(name, columns = {}, &block)
    class_name = name.to_s.pluralize.classify
    table_name = class_name.tableize
    klass    = define_model_class(class_name, &block)
    columns.each do |name, type|
      options = {}
      type, options = type if type.class == Array
      klass.property(name, type, options)
    end
    
    instance = klass.new

    create_table(klass)

    self.class.subject { instance } if self.class.respond_to?(:subject)
    instance
  end

  module ClassMethods
    # This is a macro to run validations of boolean optionals such as :nullable
    # and :scope. This macro tests all scenarios. The specs must have a
    # define_and_validate method defined.
    #
    def create_optional_boolean_specs(optional, base, options={})
      base.describe "with #{optional} option" do
        it { should define_and_validate(options.merge(optional => true)).send(optional)            }
        it { should define_and_validate(options.merge(optional => false)).send(optional, false)    }
        it { should_not define_and_validate(options.merge(optional => true)).send(optional, false) }
        it { should_not define_and_validate(options.merge(optional => false)).send(optional)       }
      end
    end

    def create_message_specs(base)
      base.describe "with message option" do
        it { should define_and_validate(:message => 'valid_message').message('valid_message') }
        it { should_not define_and_validate(:message => 'not_valid').message('valid_message') }
      end
    end
  end

end

