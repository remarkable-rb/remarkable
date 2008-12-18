module Remarkable # :nodoc:
  module Controller # :nodoc:
    module Matchers # :nodoc:
      class AssignTo < Remarkable::Matcher::Base
        include Remarkable::Controller::Helpers
        
        def initialize(*names)
          @options = names.extract_options!
          @names = names
        end

        def matches?(subject)
          @subject = subject
          assert_matcher_for(@names) do |name|
            @name = name
            
            assigned_value? &&
            is_kind_of? &&
            is_equals_expected_value?
          end
        end

        def description
          description = "assign @#{@names.to_sentence}"
          description << " as class #{@options[:class]}" if @options[:class]
          description << " which is equal to #{@options[:equals]}" if @options[:equals]
          description
        end
        
        private

        def assigned_value?
          @assigned_value = controller_assigns(@name.to_sym)
          return true if @assigned_value

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

          instantiate_variables_from_assigns do
            expected_value = if @options[:equals].is_a?(String)
              warn_level = $VERBOSE
              $VERBOSE = nil
              result = eval(@options[:equals], @spec.send(:binding), __FILE__, __LINE__) rescue @options[:equals]
              $VERBOSE = warn_level
              result
            else
              @options[:equals]
            end
            return true if @assigned_value == expected_value

            @missing = "instance variable @#{@name} expected to be #{expected_value.inspect} but was #{@assigned_value.inspect}"
            return false
          end
        end
        
        def expectation
          expectation = "assign @#{@name}"
          expectation << " as class #{@options[:class]}" if @options[:class]
          expectation << " which is equal to #{@options[:equals].inspect}" if @options[:equals]
          expectation
        end
      end

      def assign_to(*names)
        AssignTo.new(*names)
      end      
    end
  end
end
