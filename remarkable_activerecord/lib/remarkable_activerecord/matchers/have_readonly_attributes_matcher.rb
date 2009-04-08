module Remarkable
  module ActiveRecord
    module Matchers
      class HaveReadonlyAttributesMatcher < Remarkable::ActiveRecord::Base
        arguments :collection => :attributes, :as => :attribute
        collection_assertions :is_readonly?

        private

          def is_readonly?
            readonly = subject_class.readonly_attributes || []
            return readonly.include?(@attribute.to_s), :actual => readonly.to_a.inspect
          end
      end

      # Ensures that the attribute cannot be changed once the record has been
      # created.
      #
      # == Examples
      #
      #   it { should have_readonly_attributes(:password, :admin_flag) }
      #
      def have_readonly_attributes(*attributes)
        HaveReadonlyAttributesMatcher.new(*attributes).spec(self)
      end
    end
  end
end
