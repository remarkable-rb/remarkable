module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class MetadataMatcher < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        include Test::Unit::Assertions
        include ActionController::Assertions::SelectorAssertions
        
        def initialize(options)
          @options = options
        end

        def matches?(subject)
          @subject = subject
          
          assert_matcher_for(@options) do |option|
            @key, @value = option
            has_metatag?
          end
        end

        def description
          "have metatag #{@option.inspect}"
        end
        
        private
        
        def has_metatag?
          if @key.to_sym == :title
            # require "ruby-debug"; debugger
            # matcher = Spec::Rails::Matchers::AssertSelect.new(:assert_select, @response, "title", @value)
            # require "ruby-debug"; debugger
            # success = matcher.matches?(@response)
            # assert_accepts(matcher, @response)
            # html_document = @response.body
            assert_select "title", @value
          else
            assert_select "meta[name=?][content#{"*" if @value.is_a?(Regexp)}=?]", @key, @value
          end
        end
        
        def html_document
          xml = @response.content_type =~ /xml$/
          @html_document ||= HTML::Document.new(@response.body, false, xml)
        end
                
        def expectation
          "have metatag #{@key}"
        end
      end

      def render_page_with_metadata(options)
        MetadataMatcher.new(options)
      end
    end
  end
end
