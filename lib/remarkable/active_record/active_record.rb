require "remarkable/private_helpers"

module Remarkable
  class ActiveRecord
    include Remarkable::Private
  end
end

require "remarkable/active_record/associations/associations"