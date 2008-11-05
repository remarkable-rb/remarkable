module Remarkable
  class ActiveRecord
    include Remarkable::Private
  end
end

require "remarkable/active_record/associations/associations"
require "remarkable/active_record/database/database"
require "remarkable/active_record/validations/validations"