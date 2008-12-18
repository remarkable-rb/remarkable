require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  fixtures :all

  should_filter_params :ssn
  should_not_filter_params :email
end

describe UsersController do
  fixtures :all

  it { should filter_params(:ssn) }
  it { should_not filter_params(:email) }
end
