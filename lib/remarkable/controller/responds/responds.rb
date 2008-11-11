%w( respond_with ).each do |file|
  require "remarkable/controller/responds/#{file}"
end
