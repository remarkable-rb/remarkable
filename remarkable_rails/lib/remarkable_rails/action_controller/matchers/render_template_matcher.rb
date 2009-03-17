module Remarkable
  module ActionController
    module Matchers
      class RenderTemplateMatcher < Remarkable::ActionController::Base #:nodoc:

        arguments :expected

        before_assert do
          @response   = @subject.respond_to?(:response) ? @subject.response : @subject
          @controller = @spec.instance_variable_get('@controller')
        end

        assertions :rendered?, :expected_match?

        protected
          def rendered?
            @actual = if @response.respond_to?(:rendered_file)
              @response.rendered_file
            elsif @response.respond_to?(:rendered)
              case template = @response.rendered[:template]
                when nil
                  unless @response.rendered[:partials].empty?
                    path_and_file(response.rendered[:partials].keys.first).join("/_")
                  end
                when ::ActionView::Template
                  template.path
                when ::String
                  template
              end
            else
              @response.rendered_template.to_s
            end

            !@actual.blank?
          end

          def expected_match?
            actual_controller_path, actual_file     = path_and_file(@actual.to_s)
            expected_controller_path, expected_file = path_and_file(@expected.to_s)

            # Test if each given slice matches. Actual always return the full
            # file name (new.html.erb), on the other hand, the user might supply
            # only new. If the user supply all three pieces, we check if they
            # are equal, in the given order.
            #
            actual_file = actual_file.split('.')
            expected_file.split('.').each_with_index do |slice, i|
              return false unless slice == actual_file[i] || actual_file[i].nil?
            end

            actual_controller_path == expected_controller_path 
          end

          def interpolation_options
            { :expected => @expected.inspect, :actual => @actual.inspect }
          end

          def path_and_file(path)
            parts = path.split('/')
            file = parts.pop
            controller = parts.empty? ? @controller.controller_path : parts.join('/')
            return controller, file
          end

      end

      # Passes if the specified template (view file) is rendered by the
      # response. This file can be any view file, including a partial.
      #
      # <code>template</code> can include the controller path. It can also
      # include an optional extension, which you only need to use when there
      # is ambiguity.
      #
      # Note that partials must be spelled with the preceding underscore.
      #
      # == Examples
      #
      #   should render_template('list')
      #   should render_template('same_controller/list')
      #   should render_template('other_controller/list')
      #
      # # with extensions
      #   should render_template('list.rjs')
      #   should render_template('list.haml')
      #   should render_template('same_controller/list.rjs')
      #   should render_template('other_controller/list.rjs')
      #
      # # partials
      #   should render_template('_a_partial')
      #   should render_template('same_controller/_a_partial')
      #   should render_template('other_controller/_a_partial')
      #
      # == Gotcha
      #
      # Extensions check does not work in Rails 2.1.x.
      #
      def render_template(*args, &block)
        RenderTemplateMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
