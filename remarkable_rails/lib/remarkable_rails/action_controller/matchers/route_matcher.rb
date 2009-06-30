module Remarkable
  module ActionController
    module Matchers
      # Do not inherit from ActionController::Base since it don't need all macro stubs behavior.
      class RouteMatcher < Remarkable::Base #:nodoc:
        arguments :method, :path

        assertions :map_to_path?, :generate_params?

        before_assert do
          @options[:controller] ||= controller_name

          @populated_path = @path.dup

          @options.each do |key, value|
            @options[key] = value.to_param if value.respond_to?(:to_param)
            @populated_path.gsub!(key.inspect, value.to_s)
          end

          ::ActionController::Routing::Routes.reload if ::ActionController::Routing::Routes.empty?
        end

        private

          def map_to_path?
            route_for = ::ActionController::Routing::Routes.generate(@options) rescue nil
            return route_for == @populated_path, :actual => route_for.inspect
          end

          def generate_params?
            controller = @spec.send(:controller)
            env = ::ActionController::Routing::Routes.extract_request_environment(controller.request) if controller
            env ||= {}
            env[:method] = @method.to_sym
            params_from = begin
              ::ActionController::Routing::Routes.recognize_path(@populated_path, env)
            rescue
            end
            return params_from == @options, :actual => params_from.inspect
          end

          # First tries to get the controller name from the subject, then from
          # the spec class using controller class or finally, from the described
          # class.
          #
          # We have to try the described class because we don't have neither the
          # subject or the controller class in the RoutingExampleGroup.
          #
          def controller_name
            spec_class = @spec.class unless @spec.class == Class

            controller = if @subject && @subject.class.ancestors.include?(::ActionController::Base)
              @subject.class
            elsif spec_class.respond_to?(:controller_class)
              spec_class.controller_class
            elsif spec_class.respond_to?(:described_class)
              spec_class.described_class
            end

            if controller && controller.ancestors.include?(::ActionController::Base)
              controller.name.gsub(/Controller$/, '').tableize
            else
              raise ArgumentError, "I cannot guess the controller name in route. Please supply :controller as option"
            end
          end

          def interpolation_options
            { :options => @options.inspect, :method => @method.to_s.upcase, :path => @path.inspect }
          end

      end

      # Assert route generation AND route recognition.
      #
      # == Examples
      #
      #   # autodetects the :controller
      #   should_route :get,    '/posts',         :action => :index
      #
      #   # explicitly specify :controller
      #   should_route :post,   '/posts',         :controller => :posts, :action => :create
      #
      #   # non-string parameter
      #   should_route :get,    '/posts/1',       :controller => :posts, :action => :show,    :id => 1
      #
      #   # string-parameter
      #   should_route :put,    '/posts/1',       :controller => :posts, :action => :update,  :id => "1"
      #   should_route :delete, '/posts/1',       :controller => :posts, :action => :destroy, :id => 1
      #   should_route :get,    '/posts/new',     :controller => :posts, :action => :new
      #
      #   # nested routes
      #   should_route :get,    '/users/5/posts', :controller => :posts, :action => :index,   :user_id => 5
      #   should_route :post,   '/users/5/posts', :controller => :posts, :action => :create,  :user_id => 5
      #
      def route(*params, &block)
        RouteMatcher.new(*params, &block).spec(self)
      end

    end
  end
end
