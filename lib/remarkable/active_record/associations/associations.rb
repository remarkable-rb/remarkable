module Remarkable
  class Association < Remarkable::ActiveRecord
  end
end

require "remarkable/active_record/associations/belong_to"
require "remarkable/active_record/associations/have_one"
require "remarkable/active_record/associations/have_many"
require "remarkable/active_record/associations/have_and_belong_to_many"
