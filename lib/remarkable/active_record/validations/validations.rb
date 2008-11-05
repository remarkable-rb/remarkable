module Remarkable
  class Validation < Remarkable::ActiveRecord
  end
end

require "remarkable/active_record/validations/allow_values_for"
require "remarkable/active_record/validations/ensure_value_in_range"
