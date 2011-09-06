module Remarkable
  module ActiveRecord
    module Matchers
      class AllowMassAssignmentOfMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        include Remarkable::Negative
        arguments :collection => :attributes, :as => :attribute

        assertion :allows?
        collection_assertions :is_accessible?, :is_protected?

        protected

          # If no attribute is given, check if no attribute is being protected,
          # otherwise it fails.
          #
          def allows?
            return positive? unless @attributes.empty?
            protected_attributes.nil? || protected_attributes.empty?
          end

          def is_accessible?
            return positive? if accessible_attributes.nil?
            accessible_attributes.include?(@attribute.to_s)
          end

          def is_protected?
            return accessible_attributes.nil? || positive? if protected_attributes.nil?
            !protected_attributes.include?(@attribute.to_s)
          end

          def interpolation_options
            if @subject
              if positive?
                { :protected_attributes => array_to_sentence((protected_attributes || []).to_a, false, '[]') }
              else
                { :accessible_attributes => array_to_sentence((accessible_attributes || []).to_a, false, '[]') }
              end
            else
              {}
            end
          end

        private

          def accessible_attributes
            @accessible_attributes ||= unless subject_class.accessible_attributes.empty?
              subject_class.accessible_attributes
            else
              subject_class.column_names - subject_class.protected_attributes.to_a
            end
          end

          def protected_attributes
            @protected_attributes ||= if subject_class.accessible_attributes.empty?
              subject_class.protected_attributes
            else
              subject_class.column_names - subject_class.accessible_attributes.to_a
            end
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
