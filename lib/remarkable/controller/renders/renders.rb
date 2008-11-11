%w( render_with_layout render_a_form ).each do |file|
  require "remarkable/controller/renders/#{file}"
end
