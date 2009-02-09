module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class HaveNamedScope < Remarkable::Matcher::Base
        def initialize(scope_call, *args)
          @scope_opts = args.extract_options!
          @scope_call = scope_call.to_s
          @args       = args
        end

        def matches?(subject)
          @subject = subject

          assert_matcher do
            @scope = eval("#{subject_class}.#{@scope_call}")
            return_scope_object? && scope_itself_to_options?
          end
        end

        def description
          "have to scope itself to #{@scope_opts.inspect} when #{@scope_call} is called"
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end
        
        private
        
        def return_scope_object?
          return true if @scope.class == ::ActiveRecord::NamedScope::Scope
          
          @missing = "#{@scope_call} didn't return a scope object"
          return false
        end
        
        def scope_itself_to_options?
          return true if @scope_opts.empty?
          return true if @scope.proxy_options == @scope_opts
          
          @missing = "#{subject_name} didn't scope itself to #{@scope_opts.inspect}"
          return false
        end
        
        def expectation
          "#{subject_name} have to scope itself to #{@scope_opts.inspect} when #{@scope_call} is called"
        end
      end

      # Ensures that the model has a method named scope_name that returns a NamedScope object with the
      # proxy options set to the options you supply.  scope_name can be either a symbol, or a method
      # call which will be evaled against the model.  The eval'd method call has access to all the same
      # instance variables that a should statement would.
      #
      # Options: Any of the options that the named scope would pass on to find.
      #
      # Example:
      # 
      #   it { should have_named_scope(:visible, :conditions => {:visible => true}) }
      #
      # Passes for
      #
      #   named_scope :visible, :conditions => {:visible => true}
      #
      # Or for
      #
      #   def self.visible
      #     scoped(:conditions => {:visible => true})
      #   end
      #
      # You can test lambdas or methods that return ActiveRecord#scoped calls:
      #
      #   it { should have_named_scope('recent(5)', :limit => 5) }
      #   it { should have_named_scope('recent(1)', :limit => 1) }
      #
      # Passes for
      #   named_scope :recent, lambda {|c| {:limit => c}}
      #
      # Or for
      #
      #   def self.recent(c)
      #     scoped(:limit => c)
      #   end
      #
      def have_named_scope(scope_call, *args)
        HaveNamedScope.new(scope_call, *args)
      end
    end
  end
end
