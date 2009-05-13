module Remarkable
  module ActionController
    module Matchers
      class RespondWithMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :block => true

        optional :with, :body, :content_type

        before_assert do
          @response   = @subject.respond_to?(:response) ? @subject.response : @subject
          @controller = @spec.instance_variable_get('@controller')
        end

        before_assert :evaluate_content_type, :evaluate_body

        assertions :status_matches?, :body_matches?, :content_type_matches?

        protected

          def status_matches?
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

          def body_matches?
            return true unless @options.key?(:body)
            assert_contains(@response.body, @options[:body])
          end

          def content_type_matches?
            return true unless @options.key?(:content_type)
            assert_contains(@response.content_type, @options[:content_type])
          end

          def evaluate_content_type
            return unless @options.key?(:content_type)

            @options[:content_type] = case @options[:content_type]
              when Symbol
                Mime::Type.lookup_by_extension(@options[:content_type].to_s).to_s
              when Regexp
                @options[:content_type]
              else
                @options[:content_type].to_s
            end
          end

          def evaluate_body
            if @options.key?(:body) || @block
              value = @options.key?(:body) ? @options[:body] : @block
              value = @spec.instance_eval(&value) if value.is_a?(Proc)
              @options[:body] = value
            end
          end

          def interpolation_options
            if @response
              { :actual_body => @response.body.inspect,
                :actual_status => @response.response_code.inspect,
                :actual_content_type => @response.content_type.inspect }
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
      # * <tt>:content_type</tt> - The content type of the response.
      #   It accepts strings ('application/rss+xml'), mime constants (Mime::RSS),
      #   symbols (:rss) and regular expressions /rss/.
      #
      # == Examples
      #
      #   should_respond_with :success
      #   should_respond_with :error,   :body => /System error/
      #   should_respond_with 301,      :content_type => Mime::XML
      #   should_respond_with 300..399, :content_type => Mime::XML
      #
      #   it { should respond_with(:success)                              }
      #   it { should respond_with(:error).body(/System error/)           }
      #   it { should respond_with(301).content_type(Mime::XML)      }
      #   it { should respond_with(300..399).content_type(Mime::XML) }
      #
      def respond_with(*args, &block)
        options = args.extract_options!
        options.merge!(:with => args.first)
        RespondWithMatcher.new(options, &block).spec(self)
      end

      # This is just a shortcut for respond_with :body => body. Check respond_with
      # for more information.
      #
      def respond_with_body(*args, &block)
        options = args.extract_options!
        # Since body can be also given as block, only merge if any arguments was
        # actually sent.
        options.merge!(:body => args.first) unless args.empty?
        RespondWithMatcher.new(options, &block).spec(self)
      end

      # This is just a shortcut for respond_with :content_type => content_type.
      # It's also used for Shoulda compatibility. Check respond_with for more
      # information.
      #
      def respond_with_content_type(*args, &block)
        options = args.extract_options!
        options.merge!(:content_type => args.first)
        RespondWithMatcher.new(options, &block).spec(self)
      end

    end
  end
end
