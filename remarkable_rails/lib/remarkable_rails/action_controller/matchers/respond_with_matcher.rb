module Remarkable
  module ActionController
    module Matchers
      class RespondWithMatcher < Remarkable::ActionController::Base #:nodoc:

        arguments

        optional :with, :body, :with_content_type

        before_assert do
          @response   = @subject.respond_to?(:response) ? @subject.response : @subject
          @controller = @spec.instance_variable_get('@controller')
        end

        before_assert :evaluate_content_type

        assertions :status_match?, :body_match?, :content_type_match?

        protected

          def status_match?
            return true unless @options[:with] # only continue if not nil

            case @options[:with]
              when :success, :missing, :redirect, :error
                @response.send("#{@options[:with]}?")
              when Fixnum
                @response.response_code == @options[:with]
              when Symbol, String
                @response.response_code == ::ActionController::StatusCodes::SYMBOL_TO_STATUS_CODE[@options[:with].to_sym]
              when Range
                @options[:with].include?(@response.response_code)
              else
                raise ArgumentError, "I don't know how to interpret status #{@options[:with].inspect}, " <<
                                      "please give me a Fixnum, Symbol, String or Range."
            end
          end

          def body_match?
            return true unless @options.key?(:body)
            assert_contains(@response.body, @options[:body])
          end

          def content_type_match?
            return true unless @options.key?(:with_content_type)
            assert_contains(@response.content_type, @options[:with_content_type])
          end

          # Evaluate content_type before assertions to have nice descriptions
          def evaluate_content_type
            return unless @options.key?(:with_content_type)

            @options[:with_content_type] = case @options[:with_content_type]
              when Symbol
                Mime::Type.lookup_by_extension(@options[:with_content_type].to_s).to_s
              when Regexp
                @options[:with_content_type]
              else
                @options[:with_content_type].to_s
            end
          end

          def interpolation_options
            if @response
              { :current_body => @response.body.inspect,
                :status => @response.response_code.inspect,
                :content_type => @response.content_type.inspect }
            else
              { }
            end
          end

      end

      # Passes if the response has the given status. Status can be a Symbol lik
      # :success, :missing, :redirect and :error. Can be also a Fixnum, Range o
      # any other symbol which matches to any of Rails status codes. 
      #
      # == Options
      #
      # * <tt>:body</tt> - The body of the response. It accepts strings and or
      #   regular expressions. Altought you might be running your tests without
      #   integrating your views, this is useful when rendering :xml or :text.
      #
      # * <tt>:with_content_type</tt> - The content type of the response.
      #   It accepts strings ('application/rss+xml'), mime constants (Mime::RSS),
      #   symbols (:rss) and regular expressions /rss/.
      #
      # == Examples
      #
      #   should_respond_with :success
      #   should_respond_with :error,   :body => /System error/
      #   should_respond_with 301,      :with_content_type => Mime::XML
      #   should_respond_with 300..399, :with_content_type => Mime::XML
      #
      #   it { should respond_with(:success)                              }
      #   it { should respond_with(:error).body(/System error/)           }
      #   it { should respond_with(301).with_content_type(Mime::XML)      }
      #   it { should respond_with(300..399).with_content_type(Mime::XML) }
      #
      def respond_with(*args)
        options = args.extract_options!
        RespondWithMatcher.new(options.merge(:with => args.first)).spec(self)
      end

      # This is just a shortcut for respond_with :with_content_type. It's also
      # used for Shoulda compatibility. Check respond_with for more information.
      #
      def respond_with_content_type(*args)
        options = args.extract_options!
        RespondWithMatcher.new(options.merge(:with_content_type => args.first)).spec(self)
      end

      # This is just a shortcut for respond_with :body. Check respond_with for
      # more information.
      #
      def respond_with_body(*args)
        options = args.extract_options!
        RespondWithMatcher.new(options.merge(:body => args.first)).spec(self)
      end

    end
  end
end
