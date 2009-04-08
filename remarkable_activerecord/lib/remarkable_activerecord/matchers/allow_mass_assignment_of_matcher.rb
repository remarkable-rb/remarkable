module Remarkable
  module ActiveRecord
    module Matchers
      class AllowMassAssignmentOfMatcher < Remarkable::ActiveRecord::Base
        arguments :collection => :attributes, :as => :attribute

        collection_assertions :is_protected?, :is_accessible?

        protected

          def is_protected?
            protected = subject_class.protected_attributes || []
            protected.empty? || !protected.include?(@attribute.to_s)
          end

          def is_accessible?
            accessible = subject_class.accessible_attributes || []
            accessible.empty? || accessible.include?(@attribute.to_s)
          end
      end

      # Ensures that the attribute can be set on mass update.
      #
      # == Examples
      #
      #   should_allow_mass_assignment_of :email, :name
      #   it { should allow_mass_assignment_of(:email, :name) }
      #
      def allow_mass_assignment_of(*attributes)
        AllowMassAssignmentOfMatcher.new(*attributes).spec(self)
      end
    end
  end
end
