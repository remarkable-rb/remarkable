module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class AssignMatcher < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        
        def initialize(*names, &block)
          @options          = names.extract_options!
          @names            = names
          @options[:equals] = block if block_given?

          warn "[DEPRECATION] Strings given in :equals to should_assign_to won't be evaluated anymore. You can give procs or use blocks instead." if @options[:equals].is_a?(String)
        end

        def matches?(subject)
          @subject = subject

          initialize_with_spec!

          assert_matcher_for(@names) do |name|
            @name = name
            assigned_value? && is_kind_of? && is_equals_expected_value?
          end
        end

        def description
          description = "assign @#{@names.to_sentence}"
          description << " as class #{@options[:class]}" if @options[:class]
          description << " which is equal to #{@options[:equals]}" if @options[:equals]
          description
        end
        
        private

        def initialize_with_spec!
          # In Rspec 1.1.12 we can actually do:
          #
          #   @controller = @subject
          #
          @controller = @spec.instance_eval { controller }
        end

        def assigned_value?
          @assigned_value = controller_assigns(@name.to_sym)
          return true unless @assigned_value.nil?

          @missing = "the action isn't assigning to @#{@name}"
          return false
        end
        
        def is_kind_of?
          return true unless @options[:class]
          return true if @assigned_value.kind_of?(@options[:class])
          
          @missing = "@#{@name} is not a kind of #{@options[:class]}"
          return false
        end
        
        def is_equals_expected_value?
          return true unless @options[:equals]

          expected_value = if @options[:equals].is_a?(String)
            @spec.instance_eval(@options[:equals]) rescue @options[:equals]
          elsif @options[:equals].is_a?(Proc)
            @spec.instance_eval &@options[:equals]
          else
            @options[:equals]
          end
          return true if @assigned_value == expected_value

          @missing = "instance variable @#{@name} expected to be #{expected_value.inspect} but was #{@assigned_value.inspect}"
          return false
        end
        
        def expectation
          expectation = "assign @#{@name}"
          expectation << " as class #{@options[:class]}" if @options[:class]
          expectation << " which is equal to #{@options[:equals].inspect}" if @options[:equals] && !@options[:equals].is_a?(Proc)
          expectation
        end

      end

      def assign_to(*names)
        AssignMatcher.new(*names)
      end
      
    end
  end
end
