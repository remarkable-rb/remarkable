require File.dirname(__FILE__) + '/spec_helper'

describe Remarkable::Base do
  subject { [1, 2, 3] }

  it 'should provide default structure to matchers' do
    [1, 2, 3].should contain(1)
    [1, 2, 3].should contain(1, 2)
    [1, 2, 3].should contain(1, 2, 3)

    [1, 2, 3].should_not contain(4)
    [1, 2, 3].should_not contain(1, 4)
  end

  it { should contain(1) }
  it { should_not contain(10) }

end
