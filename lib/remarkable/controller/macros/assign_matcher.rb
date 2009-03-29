module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class AssignMatcher < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers

        optional :with, :with_kind_of
        
        def initialize(*names, &block)
          @options          = names.extract_options!
          @names            = names
          @options[:with] ||= block if block_given?
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
          description << " as class #{@options[:with_kind_of]}" if @options[:with_kind_of]
          description << " which is equal to #{@options[:with]}" if @options[:with]
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
          return true unless @options[:with_kind_of]
          return true if @assigned_value.kind_of?(@options[:with_kind_of])
          
          @missing = "@#{@name} is not a kind of #{@options[:with_kind_of]}"
          return false
        end
        
        def is_equals_expected_value?
          return true unless @options[:with]

          expected_value = if @options[:with].is_a?(Proc)
            @spec.instance_eval &@options[:with]
          else
            @options[:with]
          end
          return true if @assigned_value == expected_value

          @missing = "instance variable @#{@name} expected to be #{expected_value.inspect} but was #{@assigned_value.inspect}"
          return false
        end
        
        def expectation
          expectation = "assign @#{@name}"
          expectation << " as class #{@options[:with_kind_of]}" if @options[:with_kind_of]
          expectation << " which is equal to #{@options[:with].inspect}" if @options[:with] && !@options[:with].is_a?(Proc)
          expectation
        end

      end

      def assign_to(*names)
        AssignMatcher.new(*names)
      end
      
    end
  end
end
