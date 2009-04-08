# Macro stubs makes stubs and expectations easier, more readable and DRY.
#
# == Example
#
# Let's jump off to an example:
#
#   describe ProjectsController do
#     describe "responding to GET show" do
#       expects :find, :on => Project, :with => '37', :returns => proc { mock_project }
#       get     :show, :id => 37
#
#       should_assign_to :project
#       should_render_template 'show'
#
#       describe 'with mime type XML' do
#         mime Mime::XML
#
#         should_assign_to :project
#         should_respond_with_content_type Mime::XML
#       end
#     end
#   end
#
# See how the spec is readable: a ProjectsController responding to get show
# expects :find on Project which returns a proc with mock project, request the
# action show with id 37 and then should assign to project and render template
# 'show' (it will get even better soon).
#
# == Understanding it
#
# The <tt>expects</tt> method declares that a Project will receive :find with
# '37' as argument and return the value of the proc. Next, we declare we should
# perform a GET on action show with params { :id => '37' }.
# 
# Then we have two Remarkable macros: should_assign_to and should_render_template.
# Each macro before asserting will check if an action was already performed and
# if not, it runs the expectations and call the action.
#
# In other words, should assign to macro is basically doing:
#
#   it 'should assign to project' do
#     Project.should_receive(:find).with('37').and_return(mock_project)
#     get :show, :id => '37'
#     assigns(:project).should == mock_project
#   end
#
# On the other hand, should render template is doing something like this:
#
#   it 'should render template show' do
#     Project.stub!(:find).and_return(mock_project)
#     get :show, :id => '37'
#     response.should render_template('show')
#   end
#
# Now comes the first question: how each macro knows if they should perform
# expectations or stubs?
#
# By default, only should_assign_to macro performs expectations. You can change
# this behavior sending :with_stubs or :with_expectations as options:
#
#   should_assign_to       :project, :with_stubs => true
#   should_render_template 'show', :with_expectations => true
#
# This also works in the rspec way:
#
#   it { should assign_to(:project).with_stubs            }
#   it { should render_tempalte('show').with_expectations }
#
# == Readability
#
# Previously, you probably noticed that the readibility was not a 100%:
#
#  " A ProjectsController responding to get show expects :find on Project
#    which returns a proc with mock project, request the action show with
#    id 37 and then should assign to project and render template 'show'   "
#
# This is because we are reading get action show twice and there is a proc in
# the middle of the description. But, we can make it even better:
#
#   describe ProjectsController do
#     mock_models :project
#
#     describe :get => :show, :id => 37 do
#       expects :find, :on => Project, :with => '37', :returns => mock_project
#
#       should_assign_to :project
#       should_render_template 'show'
#
#       describe Mime::XML do
#         should_assign_to :project
#         should_respond_with_content_type Mime::XML
#       end
#     end
#   end
#
# You might have notices two changes:
#
#   1. We moved the "get :show, :id => 37" to the describe method. Don't worry
#      in your spec output, you will still see: "responding to GET show". Which
#      is also localized, as all Remarkable macro and matchers.
#
#   2. proc is gone. We've added a call to mock_models which creates a class
#      method that simply returns a proc and a instance method that do the
#      actual mock. In other words, it creates:
#
#        def self.mock_project
#          proc { mock_project }
#        end
#
#        def mock_project(stubs={})
#          @project ||= mock_model(Project, stubs)
#        end
#
# = Give me more!
#
# Things start to get even better when we start to talk about nested resources.
# After our ProjectsController is created, we want to create a TasksController:
#
#   describe TasksController do
#     params :project_id => '42' #=> define params for all requests
#
#     # Those two expectations get inherited in all describe groups below
#     expects :find_by_title, :on => Project, :with => '42', :returns => mock_project
#     expects :tasks, :and_return => Task
#
#     describe :get => :show, :id => '37' do
#       expects :find, :with => '37', :and_return => mock_task
#
#       should_assign_to :project, :task
#       should_render_template 'show'
#     end
#   end
#
# As you noticed, you can define parameters that will be available to all requests,
# using the method <tt>params</tt>.
#
# Finally, if you used expects chain like above, but need to write a spec by
# hand you can invoke the action and expectations with run_expectations!,
# run_stubs! and run_action!. Examples:
#
#   describe :get => :new do
#     expects :new, :on => Project, :returns => mock_project
#
#     it "should do something different" do
#       run_action!
#       # do you assertions here
#     end
#   end
#
# = Performance!
#
# Remarkable comes with a new way to speed up your tests. It runs your
# expectations and perform the action inside a before(:all), so you can do:
#
#   describe "responding to GET show" do
#     get! :show, :id => 37
#
#     should_assign_to :task
#     should_render_template :show
#   end
#
# Or in the compact way:
#
#   describe :get! => :show, :id => 37
#
# The action will be performed just once before asserting the assignment and
# the template. If any error happens while performing the action, including
# expectations not met, rspec will output an error but ALL the examples inside
# the example group (describe) won't be run.
#
# This comes with some rspec and rspec rails tweakings. Whenever using a bang
# action, if you have to run something before performing the action, you have
# to use prepend_before(:all). It's also adviced to call setup_mocks_for_rspec
# inside your before(:all), to ensure that your mocks will be created and
# removed.
#
# For example, if you want to login an user before performing the action you
# should do:
#
#   prepend_before(:all) do
#     setup_mocks_for_rspec
#     login_as(mock_user)
#   end
#
module Remarkable
  module ActionController

    module MacroStubs
      HTTP_VERBS_METHODS = [:get, :get!, :post, :post!, :put, :put!, :delete, :delete!]

      def self.included(base)
        base.extend ClassMethods
        base.class_inheritable_reader :expects_chain, :default_action, :default_mime,
                                      :default_verb, :default_params
      end

      module ClassMethods

        # Creates a chain that will be evaluated as stub or expectation. The
        # first parameter is the method expected.
        #
        # == Options
        #
        # * <tt>:on</tt> - Tell which object will receive the expected method.
        #   This option is always required.
        #
        # * <tt>:with</tt> - Tell each parameters will be sent with the expected
        #   method. This option is used only in expectations and is optional.
        #
        # * <tt>:returns</tt> - Tell what the expectations should return. Not
        #   required.
        #
        # * <tt>:times</tt> - The number of times the object will receive the
        #   method. Used only in expectations and when not given, defaults to 1.
        #
        # == Example
        #
        #   expects :new, :on => Project, :returns => :mock_project, :times => 2
        #
        def expects(*args)
          write_inheritable_array(:expects_chain, [args])
        end

        # The mime type of the request. The value given will be called transformed
        # into a string and set in the @request.env['HTTP_ACCEPT'] variable.
        #
        # == Examples
        #
        #   mime Mime::XML
        #   mime 'application/xml+rss'
        #
        def mime(mime)
          write_inheritable_attribute(:default_mime, mime.to_s)
        end

        # The params used for the request. Calls are always nested:
        #
        # == Examples
        #
        #   describe TasksController do
        #     params :project_id => 42
        #
        #     describe :get => :show, :id => 37 do
        #       # will request with params {:id => 37, :project_id => 42}
        #     end
        #   end
        #
        def params(params)
          write_inheritable_hash(:default_params, params)
        end

        [:get, :post, :put, :delete].each do |verb|
          module_eval <<-VERB, __FILE__, __LINE__
            # Declares that we want to do a #{verb} request in the given action
            # and with the given params.
            #
            # == Examples
            #
            #   #{verb} :action, :id => 42
            #
            def #{verb}(action, params={})
              params(params)
              write_inheritable_attribute(:default_verb, #{verb.inspect})
              write_inheritable_attribute(:default_action, action)
            end
          VERB
        end

        [:get!, :post!, :put!, :delete!].each do |verb|
          module_eval <<-VERB, __FILE__, __LINE__
            # Declares that we want to do a #{verb} request in the given action
            # and with the given params, but the action is performed just once
            # in the describe group. In other words, it's performed in a
            # before(:all) filter.
            #
            # == Examples
            #
            #   #{verb} :action, :id => 42
            #
            def #{verb}(action, params={})
              #{verb.to_s.chop}(action, params)
              run_callbacks_once!
            end
          VERB
        end

        # Undefine the method run_callbacks so rspec won't run them in the
        # before and after :each cycle. Then we redefine it as run_callbacks_once,
        # which will be used as an before(:all) and after(:all) filter.
        #
        def run_callbacks_once! #:nodoc:
          unless instance_methods.any?{|m| m.to_s == 'run_callbacks_once' }
            alias_method :run_callbacks_once, :run_callbacks
            class_eval "def run_callbacks(*args); end"

            before(:all) do
              setup_mocks_for_rspec
              run_callbacks_once :setup
              run_action!
              verify_mocks_for_rspec
              teardown_mocks_for_rspec
            end

            after(:all) do
              run_callbacks_once :teardown
            end
          end
        end

        # Overwrites describe to provide quick action description with I18n.
        #
        # You can now do:
        #
        #   describe :get => :show, :id => 37
        #
        # Which is the same as:
        #
        #   describe 'responding to #GET show' do
        #     get :show, :id => 37
        #
        # And do this:
        #
        #   describe Mime::XML
        #
        # Which is the same as:
        #
        #   describe 'with xml' do
        #     mime Mime::XML
        #
        # The string can be localized using I18n. An example yml file is:
        #
        #   locale:
        #     remarkable:
        #       action_controller:
        #         responding: "responding to #{{verb}} {{action}}"
        #         mime_type: "with {{format}} ({{content_type}})"
        #
        # And load the locale file with:
        #
        #   Remarkable.add_locale locale_path
        #
        def describe(*args, &block)
          options = args.first.is_a?(Hash) ? args.first : {}
          verb    = (options.keys & HTTP_VERBS_METHODS).first

          if verb
            action = options.delete(verb)
            verb   = verb.to_s

            description = Remarkable.t 'remarkable.action_controller.responding',
                                        :default => "responding to ##{verb.upcase} #{action}",
                                        :verb => verb.sub('!', '').upcase, :action => action

            send_args = [ verb, action, options ]
          elsif args.first.is_a?(Mime::Type)
            mime = args.first

            description = Remarkable.t 'remarkable.action_controller.mime_type',
                                        :default => "with #{mime.to_sym}",
                                        :format => mime.to_sym, :content_type => mime.to_s

            send_args = [ :mime, mime ]
          else # return if no special type was found
            return super(*args, &block)
          end

          args.shift
          args.unshift(description)

          # Creates an example group, send the method and eval the given block.
          #
          example_group = super(*args) do
            send(*send_args)
            instance_eval(&block)
          end
        end

        # Creates mock methods automatically.
        #
        # == Options
        #
        # * <tt>:class_method</tt> - When set to false, does not create the
        #   class method which returns a proc.
        #
        # == Examples
        #
        # Doing this:
        #
        #   describe ProjectsController do
        #     mock_models :project
        #   end
        #
        # Will create a class and instance mock method for you:
        #
        #   def self.mock_project
        #     proc { mock_project }
        #   end
        #
        #   def mock_project(stubs={})
        #     @project ||= mock_model(Project, stubs)
        #   end
        #
        # If you want to create just the instance method, you can give
        # :class_method => false as option.
        #
        def mock_models(*models)
          options = models.extract_options!
          options = { :class_method => true }.merge(options)

          models.each do |model|
            self.class_eval <<-METHOD
              #{"def self.mock_#{model}; proc { mock_#{model} }; end" if options[:class_method]}

              def mock_#{model}(stubs={})
                @#{model} ||= mock_model(#{model.to_s.classify}, stubs)
              end
            METHOD
          end
        end

      end

      protected

        # Evaluates the expectation chain as stub or expectations.
        #
        def evaluate_expectation_chain(use_expectations=true) #:nodoc:
          return if self.expects_chain.nil?

          self.expects_chain.each do |method, default_options|
            options = default_options.dup

            # Those are used both in expectations and stubs
            object       = evaluate_value(options.delete(:on))
            return_value = evaluate_value(options.delete(:returns))

            raise ScriptError, "You have to give me :on as an option when calling :expects." if object.nil?

            if use_expectations
              with  = evaluate_value(options.delete(:with))
              times = options.delete(:times) || 1

              chain = object.should_receive(method)
              chain = chain.with(with) if with
              chain = chain.exactly(times).times
            else
              chain = object.stub!(method)
            end
            chain = chain.and_return(return_value)
          end
        end

        # Instance method run_stubs! if someone wants to declare additional
        # tests and call the stubs inside of it.
        #
        def run_stubs!
          evaluate_expectation_chain(false)
        end

        # Instance method run_expectations! if someone wants to declare
        # additional tests and call the stubs inside of it.
        #
        def run_expectations!
          evaluate_expectation_chain(true)
        end

        # Run the action declared in the describe group, but before runs also
        # the expectations. If an action was already performed, it doesn't run
        # anything at all and returns false.
        #
        # The first parameter is if you want to run expectations or stubs. You
        # can also supply the verb (get, post, put or delete), which action to
        # call, parameters and the mime type. If any of those parameters are
        # supplied, they override the current definition.
        #
        def run_action!(use_expectations=true, verb=nil, action=nil, params=nil, mime=nil)
          return false if controller.send(:performed?)

          evaluate_expectation_chain(use_expectations)

          mime   ||= default_mime
          verb   ||= default_verb
          action ||= default_action
          params ||= default_params

          raise ScriptError, "No action was performed or declared." unless verb && action

          request.env["HTTP_ACCEPT"] ||= mime.to_s if mime
          send(verb, action, params)
        end

        # Evaluate a given value.
        #
        # This allows procs to be given to the expectation chain and they will
        # be evaluated in the instance binding.
        #
        def evaluate_value(duck) #:nodoc:
          if duck.is_a?(Proc)
            self.instance_eval(&duck)
          else
            duck
          end
        end

    end
  end
end
