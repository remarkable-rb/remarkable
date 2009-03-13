module Remarkable
  module ActionController
    module Matchers
      class AssignToMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :collection => :names, :as => :name, :block => :block

        optional :with, :with_kind_of
        collection_assertions :assigned_value?, :is_kind_of?, :is_equal_value?

        protected

          def assigned_value?
            !assigned_value.nil?
          end

          def is_kind_of?
            return true unless @options[:with_kind_of]
            return assigned_value.kind_of?(@options[:with_kind_of])
          end

          # Return true if no :with is given and no block is given.
          # In case :with is a proc or a block is given, we evaluate it in the
          # @spec scope.
          #
          def is_equal_value?
            value = @options[:with] || @block
            return true unless value

            value = @spec.instance_eval(&value) if value.is_a?(Proc)
            return assigned_value == value, :with => value.inspect
          end

          def assigned_value
            @subject.instance_variable_get("@#{@name}")
          end

          # Update default_i18n_options
          def default_i18n_options
            options = @options.dup
            options.update(:assign_inspect => assigned_value.inspect, :assign_class => assigned_value.class.name)
            options.update(super)
          end

      end

      # Checks if the controller assigned the variables given by name.
      #
      # == Options
      #
      # * <tt>:with</tt>         - The value to compare the assign. It can be also given as a Proc (see examples below)
      # * <tt>:with_kind_of</tt> - The expected class of the assign.
      #
      # == Examples
      #
      #   should_assign_to :user, :with_kind_of => User
      #   should_assign_to :user, :with => proc{ users(:first) }
      #   should_assign_to(:user){ users(:first) }
      #
      #   it { should assign_to(:user) }
      #   it { should assign_to(:user, :with => users(:first)) }
      #   it { should assign_to(:user, :with_kind_of => User) }
      #
      def assign_to(*names, &block)
        AssignToMatcher.new(*names, &block).spec(self)
      end

    end
  end
end
