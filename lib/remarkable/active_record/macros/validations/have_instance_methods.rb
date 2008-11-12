module Remarkable
  module Syntax

    module RSpec
      class HaveInstanceMethods
        include Remarkable::Private
        
        def initialize(*methods)
          get_options!(methods)
          @methods = methods
        end

        def matches?(klass)
          @klass = klass

          begin
            @methods.each do |method|
              unless klass.new.respond_to?(method)
                fail "#{klass.name} does not have instance method #{method}"
              end
            end

            true
          rescue Exception => e
            false
          end
        end

        def description
          "respond to instance method #{pretty_method_names}"
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

      # Ensure that the given instance methods are defined on the model.
      #
      #   it { User.should have_instance_methods(:email, :name, :name=) }
      #
      def have_instance_methods(*methods)
        Remarkable::Syntax::RSpec::HaveInstanceMethods.new(*methods)
      end
    end

    module Shoulda
    end

  end
end
