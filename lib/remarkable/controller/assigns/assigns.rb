%w( assign_to ).each do |file|
  require "remarkable/controller/assigns/#{file}"
end
