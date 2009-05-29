module Remarkable
  module ActiveRecord
    module Matchers
      class AllowMassAssignmentOfMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :attributes, :as => :attribute

        assertion :allows?
        collection_assertions :is_protected?, :is_accessible?

        protected

          # If no attribute is given, check if no attribute is being protected,
          # otherwise it fails.
          #
          def allows?
            !@attributes.empty? || protected_attributes.empty?
          end

          def is_protected?
            protected_attributes.empty? || !protected_attributes.include?(@attribute.to_s)
          end

          def is_accessible?
            accessible_attributes.empty? || accessible_attributes.include?(@attribute.to_s)
          end

          def interpolation_options
            if @subject
              { :protected_attributes => array_to_sentence(protected_attributes.to_a, false, '[]') }
            else
              {}
            end
          end

        private

          def accessible_attributes
            @accessible_attributes ||= subject_class.accessible_attributes || []
          end

          def protected_attributes
            @protected_attributes ||= subject_class.protected_attributes || []
          end
      end

      # Ensures that the attribute can be set on mass update.
      #
      # == Examples
      #
      #   should_allow_mass_assignment_of :email, :name
      #   it { should allow_mass_assignment_of(:email, :name) }
      #
      def allow_mass_assignment_of(*attributes, &block)
        AllowMassAssignmentOfMatcher.new(*attributes, &block).spec(self)
      end
    end
  end
end
