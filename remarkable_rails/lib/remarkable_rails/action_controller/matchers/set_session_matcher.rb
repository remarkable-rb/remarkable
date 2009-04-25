module Remarkable
  module ActionController
    module Matchers
      class SetSessionMatcher < Remarkable::ActionController::Base #:nodoc:
        arguments :collection => :keys, :as => :key, :block => true

        optional :to, :block => true

        assertion :is_not_empty?, :contains_value?
        collection_assertions :assigned_value?, :is_equal_value?

        before_assert :evaluate_expected_value

        private

          # When no keys are given:
          #
          #   should set_session
          #
          # We check if the session is not empty.
          #
          def is_not_empty?
            !(@keys.empty? && session.empty?)
          end

          # When no keys are given and a comparision value is given:
          #
          #   should set_session.to(1)
          #
          # We check if any of the session data contains the given value.
          #
          def contains_value?
            return true unless @keys.empty? && value_to_compare?
            assert_contains(session.values, @options[:to])
          end

          def assigned_value?
            session.key?(@key)
          end

          # Returns true if :to is not given and no block is given.
          # In case :to is a proc or a block is given, we evaluate it in the
          # @spec scope.
          #
          def is_equal_value?
            return true unless value_to_compare?
            assert_contains([session[@key]], @options[:to])
          end

          def session
            raw_session.with_indifferent_access.except(:flash)
          end

          def raw_session
            @subject ? @subject.response.session.data : {}
          end

          def value_to_compare?
            @options.key?(:to) || @block
          end

          def interpolation_options
            { :session_inspect => raw_session.except('flash').symbolize_keys!.inspect }
          end

          # Evaluate procs before assert to avoid them appearing in descriptions.
          def evaluate_expected_value
            if value_to_compare?
              value = @options.key?(:to) ? @options[:to] : @block
              value = @spec.instance_eval(&value) if value.is_a?(Proc)
              @options[:to] = value
            end
          end

      end

      # Ensures that the given session keys were set. If you want to check that
      # a variable is not being set, just do:
      #
      #   should_not_set_session :user
      #
      # If you want to assure that a variable is being set to nil, do instead:
      #
      #   should_set_session :user, :to => nil
      #
      # == Options
      #
      # * <tt>:to</tt> - The value to compare the session key.
      #   It accepts procs and be also given as a block (see examples below).
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
