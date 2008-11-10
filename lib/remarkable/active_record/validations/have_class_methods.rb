module Remarkable
  class HaveClassMethods < Remarkable::Validation
    def initialize(*methods)
      get_options!(methods)
      @methods = methods
    end

    def matches?(klass)
      @klass = klass

      begin
        @methods.each do |method|
          unless klass.respond_to?(method)
            fail "#{klass.name} does not have class method #{method}"
          end
        end

        true
      rescue Exception => e
        false
      end
    end

    def description
      "respond to class method #{pretty_method_names}"
    end

    def failure_message
      @failure_message || "expected that #{pretty_method_names} #{@methods.size > 1 ? "is" : "are"} defined on #{@klass.name}, but it didn't"
    end

    def negative_failure_message
      "expected that #{pretty_method_names} #{@methods.size > 1 ? "aren't" : "isn't"} defined on #{@klass.name}, but it did"
    end
    
    def pretty_method_names
      @methods.map { |m| "##{m}" }.to_sentence
    end
  end
end

# Ensure that the given class methods are defined on the model.
#
#   it { User.should have_class_methods(:find, :destroy) }
#
def have_class_methods(*methods)
  Remarkable::HaveClassMethods.new(*methods)
end
