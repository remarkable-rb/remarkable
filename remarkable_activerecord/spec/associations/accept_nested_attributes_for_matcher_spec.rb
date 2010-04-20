require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

if RAILS_VERSION >= '2.3.3'
  describe 'accept_nested_attributes_for' do
    include ModelBuilder

    def define_and_validate(default=:category, options={})
      @model = define_model :product do
        has_one :category
        has_many :orders
        has_many :labels
        has_many :tags, :autosave => true

        accepts_nested_attributes_for :category, options
        accepts_nested_attributes_for :orders, options
      end

      accept_nested_attributes_for *default
    end

    describe 'messages' do

      it 'should contain a description' do
        matcher = define_and_validate
        matcher.description.should == 'accept nested attributes for category'

        matcher.allow_destroy
        matcher.description.should == 'accept nested attributes for category allowing destroy'

        matcher.accept(:name => 'jose')
        matcher.accept(:name => 'maria')
        matcher.description.should == 'accept nested attributes for category allowing destroy and accepting {:name=>"jose"} and {:name=>"maria"}'
      end

      it 'should set association_match? message' do
        matcher = define_and_validate(:nothing)
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Product to have association nothing, but does not'
      end

      it 'should set is_autosave? message' do
        matcher = define_and_validate(:labels)
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Product to have association labels with autosave true, got false'
      end

      it 'should set responds_to_attributes? message' do
        matcher = define_and_validate(:tags)
        matcher.matches?(@model)
        matcher.failure_message.should == 'Expected Product to respond to :tags_attributes=, but does not'
      end

      it 'should set allows_destroy? message' do
        matcher = define_and_validate(:category, :allow_destroy => false)
        matcher.allow_destroy.matches?(@model)
        matcher.failure_message.should == 'Expected Product with allow destroy equals to true, got false'
      end

      it 'should set accepts? message' do
        matcher = define_and_validate(:category, :reject_if => proc{|a| true })
        matcher.accept({}).matches?(@model)
        matcher.failure_message.should == 'Expected Product to accept attributes {} for category, but does not'
      end

      it 'should set rejects? message' do
        matcher = define_and_validate(:category, :reject_if => proc{|a| false })
        matcher.reject({}).matches?(@model)
        matcher.failure_message.should == 'Expected Product to reject attributes {} for category, but does not'
      end

    end

    describe 'matchers' do
      it { should define_and_validate(:category) }
      it { should define_and_validate(:orders) }

      it { should_not define_and_validate(:nothing) }
      it { should_not define_and_validate(:labels) }
      it { should_not define_and_validate(:tags) }

      describe 'with allow destroy as option' do
        it { should define_and_validate(:category, :allow_destroy => true).allow_destroy }
        it { should define_and_validate(:category, :allow_destroy => false).allow_destroy(false) }
        it { should_not define_and_validate(:category, :allow_destroy => false).allow_destroy }
        it { should_not define_and_validate(:category, :allow_destroy => true).allow_destroy(false) }

        it { should define_and_validate(:orders, :allow_destroy => true).allow_destroy }
        it { should define_and_validate(:orders, :allow_destroy => false).allow_destroy(false) }
        it { should_not define_and_validate(:orders, :allow_destroy => false).allow_destroy }
        it { should_not define_and_validate(:orders, :allow_destroy => true).allow_destroy(false) }
      end

      describe 'with accept as option' do
        it { should define_and_validate(:category, :reject_if => proc{ |a| a[:name].blank? }).accept({ :name => 'Jose' }) }
        it { should define_and_validate(:category, :reject_if => proc{ |a| a[:name].blank? }).accept({ :name => 'Jose' }, { :name => 'Maria' }) }
        it { should_not define_and_validate(:category, :reject_if => proc{ |a| a[:name].blank? }).accept({ :name => '' }) }
      end

      describe 'with reject as option' do
        it { should define_and_validate(:category, :reject_if => proc{ |a| !a[:name].blank? }).reject({ :name => 'Jose' }) }
        it { should define_and_validate(:category, :reject_if => proc{ |a| !a[:name].blank? }).reject({ :name => 'Jose' }, { :name => 'Maria' }) }
        it { should_not define_and_validate(:category, :reject_if => proc{ |a| !a[:name].blank? }).reject({ :name => '' }) }
      end
    end

    describe 'macros' do
      before(:each){ define_and_validate(:category, :allow_destroy => true, :reject_if => proc{ |a| a[:name].blank? }) }

      should_accept_nested_attributes_for :category
      should_accept_nested_attributes_for :category, :allow_destroy => true
      should_accept_nested_attributes_for :category, :accept => { :name => 'Jose' }
      should_accept_nested_attributes_for :category, :accept => [ { :name => 'Jose' }, { :name => 'Maria' } ]
      should_accept_nested_attributes_for :category, :reject => [ { :name => '' } ]

      should_accept_nested_attributes_for :category do |m|
        m.allow_destroy
        m.accept :name => "Jose"
        m.accept :name => "Maria"
        m.reject :name => ""
      end

      should_not_accept_nested_attributes_for :nothing
      should_not_accept_nested_attributes_for :labels
      should_not_accept_nested_attributes_for :tags
      should_not_accept_nested_attributes_for :category, :allow_destroy => false
      should_not_accept_nested_attributes_for :category, :accept => [ { :name => '' } ]
      should_not_accept_nested_attributes_for :category, :reject => [ { :name => 'Jose' }, { :name => 'Maria' } ]
    end
  end
end
