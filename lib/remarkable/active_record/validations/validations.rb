module Remarkable
  class Validation < Remarkable::ActiveRecord
  end
end

require "remarkable/active_record/validations/allow_values_for"
require "remarkable/active_record/validations/ensure_value_in_range"
require "remarkable/active_record/validations/only_allow_numeric_values_for"
require "remarkable/active_record/validations/ensure_length_at_least"
require "remarkable/active_record/validations/ensure_length_in_range"
require "remarkable/active_record/validations/ensure_length_is"
require "remarkable/active_record/validations/require_attributes"
require "remarkable/active_record/validations/require_acceptance_of"
require "remarkable/active_record/validations/require_unique_attributes"
