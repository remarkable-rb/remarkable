# Adds a DSL to controller specs to make stub and expectations easier and DRY.
#
# Let's start with an example:
#
#   describe ProjectsController do
#     describe "responding to GET show" do
#       expects :find, :on => Project, :with => '37', :returns => proc { mock_project }
#       get     :show, :id => '37'
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
# The receive method declare that a Project will receive :find with '37' as
# argument and return the value of the proc.
#
# The first thing you should know is that the proc given is evaluated inside
# the "it" example.
#
# Before each macro run, it will convert such information into a stub or into a
# expectation. Using stubs and expectations in controllers tests is important
# because you will be sure that your controller tests will run isolated from
# your models and from your views.
#
# For more information, check this article from David Chelimsky:
#
#   http://blog.davidchelimsky.net/2008/12/11/a-case-against-a-case-against-mocking-and-stubbing
#
# Going back to our example, the second thing you have to know is that you
# don't have to play with proc all the time. You can call mock_project and it
# will generate a mock for you on the fly:
##   expects :find, :on => Project, :with => '37', :returns => mock_project
#
# The last bit of customization is possible giving the action parameters to
# the describe block:
#
#   describe :get => :show, :id => '37' do
#     expects :find, :on => Project, :with => '37', :returns => proc { mock_project }
#
#     should_assign_to :project
#     should_render_template 'show'
#   end
#
# This will automatically generate a description:
#
#   describe 'responding to GET show'
#
# That can even be localized.
#
# = Give me more!
#
# Things start to get even better when we start to talk about nested resources.
# After our ProjectsController is created, we want to create a TasksController.
#
# You do the scaffold and have to go through all that pain of changing your
# expectations and stubs, right? Not anymore! Check this out:
#
#   describe TasksController do
#     expects :find_by_title, :on => Project, :with => '42', :returns => :mock_project
#     expects :tasks, :and_return => Task
#
#     params :project_id => '42' #=> define params for all requests
#
#     describe :get => :show, :id => '37' do
#       receives :find, :with => '37', :and_return => :mock_task
#
#       should_assign_to :project, :task
#       should_render_template 'show'
#     end
#   end
#
# As you noticed, expectations and stubs are inherited. You can including define
# parameter that will be available to all requests, using the method <tt>params</tt>
#
module Remarkable
  module ActionController
    module MacroStubs
      HTTP_VERBS = [ :get, :post, :put, :delete ]

      def self.included(base)
        base.extend ClassMethods
        base.class_inheritable_reader :receive_chain, :default_action, :default_mime, :default_verb, :default_params
      end

      # Defines :expects, :mime, :params, :get, :post, :put and :delete as class
      # methods.
      #
      module ClassMethods

        def expects(*args)
          write_inheritable_array(:receive_chain, [args])
        end

        def mime(mime)
          write_inheritable_attribute(:default_mime, mime.to_s)
        end

        def params(params)
          write_inheritable_hash(:default_params, params)
        end

        [:get, :post, :put, :delete].each do |verb|
          module_eval <<-VERB, __FILE__, __LINE__
            def #{verb}(action, params={})
              params(params)
              write_inheritable_attribute(:default_verb, #{verb.inspect})
              write_inheritable_attribute(:default_action, action)
            end
          VERB
        end

        # Overwrites describe to provide quick action description with I18n.
        #
        def describe(*args, &block)
          options = args.first.is_a?(Hash) ? args.first : {}
          verb    = options.keys & HTTP_VERBS

          unless verb.empty?
            action = options.delete(verb)

            description = Remarkable.t 'remarkable.action_controller.responding',
                                        :default => "responding with ##{verb.upcase} #{action}",
                                        :verb => verb.upcase, :action => action

            args.shift
            args.unshift(description)

            super(*args) do
              send(verb, action, options)
              yield
            end
          else
            super(*args, &block)
          end
        end

      end

      protected

        def evaluate_expectation_chain(evaluate_with_stubs=true)
          object_to_stub = subject

          self.receive_chain.each do |method, default_options|
            options        = default_options.dup
            object_to_stub = evaluate_value(options.delete(:on)) || object_to_stub
            return_value   = evaluate_value(options.delete(:returns))
            with           = evaluate_value(options.delete(:with))
            times          = options.delete(:times) || 1

            raise ArgumentError, "You gave me :on equal nil." if object_to_stub.nil?

            # Now we actually do the stubbing or expectations
            #
            chain = object_to_stub
            if evaluate_with_stubs
              chain = chain.stub!(method)
            else
              chain = chain.should_receive(method)
              chain = chain.with(with) if with
              chain = chain.exactly(times).times
            end
            chain = chain.and_return(return_value)

            object_to_stub = return_value
          end
        end

        # Instance method run_stubs! if someone wants to declare additional
        # tests and call the stubs inside of it.
        def run_stubs!
          evaluate_expectation_chain(true)
        end

        # Instance method run_expectations! if someone wants to declare
        # additional tests and call the stubs inside of it.
        def run_expectations!
          evaluate_expectation_chain(false)
        end

        def run_action!(stub=true, verb=nil, action=nil, params={}, mime=nil)
          # Execute the expectation chain
          evaluate_expectation_chain(stub)

          mime   ||= default_mime
          verb   ||= default_verb
          action ||= default_action
          params   = (default_params || {}).merge(params)

          raise ScriptError, 'You have to declare if I should do a :get, :post, :put or :delete' unless verb
          raise ScriptError, 'You have to say which action I should call'                        unless action

          # Set the mime type
          request.env["HTTP_ACCEPT"] ||= mime.to_s if mime

          # Run the action
          send(verb, action, params)
        end

        # Evaluate a given value.
        #
        # This allows procs to be given to the receive chain and they will be
        # evaluated in the instance binding.
        #
        def evaluate_value(duck)
          if duck.is_a? Proc
            self.instance_eval &duck
          else
            duck
          end
        end

    end
  end
end
