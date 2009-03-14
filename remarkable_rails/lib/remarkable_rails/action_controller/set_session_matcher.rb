module Remarkable
  module ActionController
    module Matchers
      class SetSessionMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :collection => :keys, :as => :key, :block => :block

        optional :to
        collection_assertions :assigned_value?, :is_equal_value?

        private

          def assigned_value?
            !assigned_value.nil? || value_to_compare?
          end

          # Returns true if :to is not given and no block is given.
          # In case :to is a proc or a block is given, we evaluate it in the
          # @spec scope.
          #
          def is_equal_value?
            return true unless value_to_compare?

            value = @options[:to] || @block
            value = @spec.instance_eval(&value) if value.is_a?(Proc)
            return assigned_value == value, :to => value.inspect
          end

          def session
            @subject ? @subject.response.session.data : {}
          end

          def assigned_value
            session[@key]
          end

          def value_to_compare?
            @options.key?(:to) || @block
          end

          def interpolation_options
            { :session_inspect => session.symbolize_keys!.inspect }
          end
      end

      # Ensures that a session keys were set.
      #
      # == Options
      #
      # * <tt>:to</tt> - The value to compare the session key. It accepts procs and be also given as a block (see examples below)
      #
      # == Examples
      #
      #   should_set_session :user_id, :user
      #   should_set_session :user_id, :to => 2
      #   should_set_session :user, :to => proc{ users(:first) }
      #   should_set_session(:user){ users(:first) }
      #
      #   it { should set_session(:user_id, :user) }
      #   it { should set_session(:user_id, :to => 2) }
      #   it { should set_session(:user, :to => users(:first)) }
      #
      def set_session(*args, &block)
        SetSessionMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
