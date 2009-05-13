require File.join(File.dirname(__FILE__), 'respond_with_matcher') 

module Remarkable
  module ActionController
    module Matchers
      class RenderTemplateMatcher < RespondWithMatcher #:nodoc:
        prepend_optional :template, :layout

        assertions :rendered?, :template_matches?, :layout_matches?

        protected

          def rendered?
            return true unless @options.key?(:template)

            @actual = if @response.respond_to?(:rendered_file)
              @response.rendered_file
            elsif @response.respond_to?(:rendered)
              case template = @response.rendered[:template]
                when nil
                  unless @response.rendered[:partials].empty?
                    path_and_file(@response.rendered[:partials].keys.first).join("/_")
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

          def template_matches?
            return true unless @options[:template] # only continue if not nil

            actual_controller_path, actual_file     = path_and_file(@actual.to_s)
            expected_controller_path, expected_file = path_and_file(@options[:template].to_s)

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

          def layout_matches?
            return true unless @options.key?(:layout)
            @response.layout.to_s.split('/').last.to_s == @options[:layout].to_s
          end

          def path_and_file(path)
            parts = path.split('/')
            file = parts.pop
            controller = parts.empty? ? @controller.controller_path : parts.join('/')
            return controller, file
          end

          def interpolation_options
            if @response
              super.merge!(:actual_layout => @response.layout.inspect, :actual_template => @actual.inspect)
            else
              super.merge!(:actual_template => @actual.inspect)
            end
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
      # == Options
      #
      # * <tt>:layout</tt> - The layout used when rendering the template.
      #
      # All other options in <tt>respond_with</tt> are also available.
      #
      # == Examples
      #
      #   should_render_template 'list'
      #   should_render_template 'same_controller/list'
      #   should_render_template 'other_controller/list'
      #
      # # with extensions
      #   should_render_template 'list.rjs'
      #   should_render_template 'list.haml'
      #   should_render_template 'same_controller/list.rjs'
      #   should_render_template 'other_controller/list.rjs'
      #
      # # partials
      #   should_render_template '_a_partial'
      #   should_render_template 'same_controller/_a_partial'
      #   should_render_template 'other_controller/_a_partial'
      #
      # # with options
      #   should_render_template 'list', :layout => 'users'
      #   should_render_template 'list', :content_type => :xml
      #   should_render_template 'list', :content_type => /xml/
      #   should_render_template 'list', :content_type => Mime::XML
      #
      #   it { should render_template('list').layout('users') }
      #   it { should render_template('list').content_type(:xml) }
      #   it { should render_template('list').content_type(/xml/) }
      #   it { should render_template('list').content_type(Mime::XML) }
      #
      # == Gotcha
      #
      # Extensions check does not work in Rails 2.1.x.
      #
      def render_template(*args, &block)
        options = args.extract_options!
        options.merge!(:template => args.first)
        RenderTemplateMatcher.new(options, &block).spec(self)
      end

      # This is just a shortcut for render_template :layout => layout. It's also
      # used for Shoulda compatibility. Check render_template for more information.
      #
      def render_with_layout(*args, &block)
        options = args.extract_options!
        options.merge!(:layout => args.first)
        RenderTemplateMatcher.new(options, &block).spec(self)
      end

      # This is just a shortcut for render_template :layout => nil. It's also
      # used for Shoulda compatibility. Check render_template for more information.
      #
      def render_without_layout(options={}, &block)
        options.merge!(:layout => nil)
        RenderTemplateMatcher.new(options, &block).spec(self)
      end

    end
  end
end
