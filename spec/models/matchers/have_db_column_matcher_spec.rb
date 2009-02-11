require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "ColumnMatcher" do

  describe "in an existing database column" do
    before(:each) { define_model :superhero, { :nickname => :string } }
    subject { Superhero.new }

    it { should have_db_column(:nickname) }
  end

  describe "in a nonexistent database column" do
    before(:each) { define_model :superhero }
    subject { Superhero.new }

    it { should_not have_db_column(:nickname) }
  end

  describe "in a column of correct type" do
    before(:each) { define_model :superhero, { :nickname => :string } }
    subject { Superhero.new }

    it { should have_db_column(:nickname).type(:string) }
  end

  describe "in a column of wrong type" do
    before(:each) { define_model :superhero, { :nickname => :integer } }
    subject { Superhero.new }

    it { should_not have_db_column(:nickname).type(:string) }
  end

  describe "in a column of correct precision" do
    before(:each) do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 5
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should have_db_column(:salary).with_options(:precision => 5) }
  end

  describe "in a a column of wrong precision" do
    before(:each) do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 15
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should_not have_db_column(:salary).with_options(:precision => 5) }
  end

  describe "in a column of correct limit" do
    before(:each) do
      create_table 'superheros' do |table|
        table.string :email, :limit => 255
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should have_db_column(:email).type(:string).with_options(:limit => 255) }
  end

  describe "in a column of wrong limit" do
    before(:each) do
      create_table 'superheros' do |table|
        table.string :email, :limit => 500
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should_not have_db_column(:email).type(:string).with_options(:limit => 255) }
  end

  describe "in a column of correct default" do
    before(:each) do
      create_table 'superheros' do |table|
        table.boolean :admin, :default => false
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should have_db_column(:admin).type(:boolean).with_options(:default => false) }
  end

  describe "in a column of wrong default" do
    before(:each) do
      create_table 'superheros' do |table|
        table.boolean :admin, :default => true
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should_not have_db_column(:admin).type(:boolean).with_options(:default => false) }
  end

  describe "in a column of correct null" do
    before(:each) do
      create_table 'superheros' do |table|
        table.boolean :admin, :null => false
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should have_db_column(:admin).type(:boolean).with_options(:null => false) }
  end

  describe "in a column of wrong null" do
    before(:each) do
      create_table 'superheros' do |table|
        table.boolean :admin, :null => true
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should_not have_db_column(:admin).type(:boolean).with_options(:null => false) }
  end

  describe "in a column of correct scale" do
    before(:each) do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 10, :scale => 2
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should have_db_column(:salary).type(:decimal).with_options(:scale => 2) }
  end

  describe "in a column of wrong scale" do
    before(:each) do
      create_table 'superheros' do |table|
        table.decimal :salary, :precision => 10, :scale => 4
      end
      define_model_class 'Superhero'
    end
    subject { Superhero.new }

    it { should_not have_db_column(:salary).type(:decimal).with_options(:scale => 2) }
  end

end
