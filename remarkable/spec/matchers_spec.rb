require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Remarkable::Matchers do
  it 'should include matchers in a specified target' do
    klass = Class.new

    module Foo
      module Matchers
      end
    end

    Remarkable.include_matchers!(Foo, klass)
    klass.ancestors.should include(Foo::Matchers)

    meta = (class << klass; self; end)
    meta.ancestors.should include(Remarkable::Macros)
    meta.ancestors.should include(Remarkable::Pending)
  end

  it 'should include matchers in Remarkable::Matchers' do
    klass = Class.new

    module Foo
      module Matchers
      end
    end

    Remarkable.include_matchers!(Foo, klass)
    Remarkable::Matchers.ancestors.should include(Foo::Matchers)
    (class << Remarkable::Matchers; self; end).ancestors.should include(Foo::Matchers)
  end

  it 'should raise an error if include matchers is called without target and rspec is not loaded' do
    Remarkable.stub!(:rspec_defined?).and_return(false)
    lambda {
      Remarkable.include_matchers!(String)
    }.should raise_error(ArgumentError, "You haven't supplied the target to include_matchers! and RSpec is not loaded, so we cannot infer one.")
  end

  it 'should not include modules twice' do
    klass = Class.new
    meta = (class << klass; self; end)

    meta.should_receive(:ancestors).twice.and_return([Remarkable::Pending, Remarkable::Macros])
    klass.should_not_receive(:extend).with(Remarkable::Pending)
    klass.should_not_receive(:extend).with(Remarkable::Macros)

    Remarkable.include_matchers!(Module.new, klass)
  end
end
