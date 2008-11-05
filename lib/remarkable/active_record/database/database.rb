module Remarkable
  class Database < Remarkable::ActiveRecord
  end
end

require "remarkable/active_record/database/have_db_columns"
require "remarkable/active_record/database/have_db_column"
require "remarkable/active_record/database/have_indices"
