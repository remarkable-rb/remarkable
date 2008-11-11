require "remarkable/controller/helpers"
require "remarkable/controller/macros"

%w( respond_with
    respond_with_content_type
    render_with_layout
    render_a_form
    render_template
    assign_to
    route
    redirect_to ).each { |file| require "remarkable/controller/macros/#{file}" }
