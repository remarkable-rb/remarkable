module Remarkable
  module ActiveRecord
    module Syntax

      module RSpec
        class HaveClassMethods
          include Remarkable::Private

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

        # Ensure that the given class methods are defined on the model.
        #
        #   it { should have_class_methods(:find, :destroy) }
        #
        def have_class_methods(*methods)
          Remarkable::ActiveRecord::Syntax::RSpec::HaveClassMethods.new(*methods)
        end
      end

      module Shoulda
        # Ensure that the given class methods are defined on the model.
        #
        #   should_have_class_methods :find, :destroy
        #
        def should_have_class_methods(*methods)
          get_options!(methods)
          klass = model_class
          methods.each do |method|
            it "should respond to class method ##{method}" do
              unless klass.respond_to?(method)
                fail_with "#{klass.name} does not have class method #{method}"
              end
            end
          end
        end
      end

    end
  end
end
