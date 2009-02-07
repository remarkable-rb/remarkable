module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class Route < Remarkable::Matcher::Base
        def initialize(method, path, options)
          @method  = method
          @path    = path
          @options = options
        end

        def matches?(subject)
          @subject = subject

          initialize_with_spec!

          unless @options[:controller]
            @options[:controller] = @controller.class.name.gsub(/Controller$/, '').tableize
          end
          @options[:controller] = @options[:controller].to_s
          @options[:action] = @options[:action].to_s

          @populated_path = @path.dup
          @options.each do |key, value|
            @options[key] = value.to_param if value.respond_to?(:to_param)
            @populated_path.gsub!(key.inspect, value.to_s)
          end

          ActionController::Routing::Routes.reload if ActionController::Routing::Routes.empty?
          assert_matcher do
            map_to_path? &&
            generate_params?
          end
        end

        def description
          expectation
        end

        private

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @controller = @subject
          #
          @controller = @spec.instance_eval { controller }
        end

        def map_to_path?
          route_for = ActionController::Routing::Routes.generate(@options) rescue nil
          return true if route_for == @populated_path

          @missing = "not map #{@options.inspect} to #{@path.inspect}"
          return false
        end

        def generate_params?
          params_from = ActionController::Routing::Routes.recognize_path(@populated_path, :method => @method.to_sym)
          return true if params_from == @options

          @missing = "not generate params #{@options.inspect} from #{@method.to_s.upcase} to #{@path.inspect}"
          return false
        end

        def expectation
          "route #{@method.to_s.upcase} #{@populated_path} to/from #{@options.inspect}"
        end
      end

      def route(method, path, options)
        Route.new(method, path, options)
      end
    end
  end
end
