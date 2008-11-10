module Remarkable
  class HaveNamedScope < Remarkable::Validation
    def initialize(scope_call, *args)
      @scope_opts = args.extract_options!
      @scope_call = scope_call.to_s
      @args       = args
    end

    def matches?(klass)
      @klass = klass

      begin
        scope = eval("#{klass}.#{@scope_call}")

        unless scope.class == ::ActiveRecord::NamedScope::Scope
          fail "#{@scope_call} didn't return a scope object"
        end

        unless @scope_opts.empty? 
          unless scope.proxy_options == @scope_opts
            fail "#{klass.name} didn't scope itself to #{@scope_opts.inspect}"
          end
        end

        true
      rescue Exception => e
        false
      end
    end

    def description
      "have to scope itself to #{@scope_opts.inspect} when #{@scope_call} is called"
    end

    def failure_message
      @failure_message || "expected that #{klass.name} has a method named #{@scope_call} that returns a NamedScope object with the proxy options set to the options you supply, but it didn't"
    end

    def negative_failure_message
      "expected that #{klass.name} hasn't a method named #{@scope_call} that returns a NamedScope object with the proxy options set to the options you supply, but it did"
    end
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
#   it { User.should have_named_scope(:visible, :conditions => {:visible => true}) }
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
#   it { User.should have_named_scope('recent(5)', :limit => 5) }
#   it { User.should have_named_scope('recent(1)', :limit => 1) }
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
  Remarkable::HaveNamedScope.new(scope_call, *args)
end
