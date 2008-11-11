%w( render_with_layout render_without_layout ).each do |file|
  require "remarkable/controller/renders/#{file}"
end
