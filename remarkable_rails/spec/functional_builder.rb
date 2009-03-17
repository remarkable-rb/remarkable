# This is based on Shoulda model builder for Test::Unit.
#
module FunctionalBuilder
  def self.included(base)
    base.class_eval do
      return unless base.name =~ /^Spec/

      base.controller_name 'application'
      base.integrate_views false

      after(:each) do
        if @defined_constants
          @defined_constants.each do |class_name| 
            Object.send(:remove_const, class_name)
          end
        end
      end
    end
  end

  def build_response(&block)
    klass = defined?(ExamplesController) ? ExamplesController : define_controller('Examples')
    block ||= lambda { render :nothing => true }
    klass.class_eval { define_method(:example, &block) }

    @controller = klass.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :example

    self.class.subject { @controller }
  end

  def define_controller(class_name, &block)
    class_name = class_name.to_s
    class_name << 'Controller' unless class_name =~ /Controller$/
    define_constant(class_name, ApplicationController, &block)
  end

  def define_constant(class_name, base, &block)
    class_name = class_name.to_s.camelize

    klass = Class.new(base)
    Object.const_set(class_name, klass)

    klass.class_eval(&block) if block_given?

    @defined_constants ||= []
    @defined_constants << class_name

    klass
  end
end
