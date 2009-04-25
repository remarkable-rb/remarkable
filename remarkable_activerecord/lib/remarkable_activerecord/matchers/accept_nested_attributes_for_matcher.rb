module Remarkable
  module ActiveRecord
    module Matchers
      class AcceptNestedAttributesForMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :associations, :as => :association

        collection_assertions :association_exists?, :is_autosave?, :responds_to_attributes?,
                              :allows_destroy?, :accepts?, :rejects?

        optionals :allow_destroy, :default => true
        optionals :accept, :reject, :splat => true

        protected

          def association_exists?
            reflection
          end

          def is_autosave?
            reflection.options[:autosave] == true
          end

          def responds_to_attributes?
            @subject.respond_to?(:"#{@association}_attributes=", true)
          end

          def allows_destroy?
            return true unless @options.key?(:allow_destroy)

            @subject.instance_eval <<-ALLOW_DESTROY
              def assign_nested_attributes_for_#{reflection_type}_association(association, attrs, allow)
                return allow
              end
            ALLOW_DESTROY

            actual = @subject.send(:"#{@association}_attributes=", {})
            return actual == @options[:allow_destroy], :actual => actual
          end

          def accepts?
            return true unless @options.key?(:accept)

            [@options[:accept]].flatten.each do |attributes|
              return false, :attributes => attributes.inspect if reject_if_proc.call(attributes)
            end

            true
          end

          def rejects?
            return true unless @options.key?(:reject)

            [@options[:reject]].flatten.each do |attributes|
              return false, :attributes => attributes.inspect unless reject_if_proc.call(attributes)
            end

            true
          end

        private

          def reflection
            @reflection ||= subject_class.reflect_on_association(@association.to_sym)
          end

          def reflection_type
            case reflection.macro
              when :has_one, :belongs_to
                :one_to_one
              when :has_many, :has_and_belongs_to_many
                :collection
            end
          end

          def reject_if_proc
            subject_class.reject_new_nested_attributes_procs[@association.to_sym]
          end

      end

      # Ensures that the model accepts nested attributes for the given associations.
      #
      # == Options
      #
      # * <tt>allow_destroy</tt> - When true allows the association to be destroyed
      # * <tt>accept</tt> - attributes that should be accepted by the :reject_if proc
      # * <tt>reject</tt> - attributes that should be rejected by the :reject_if proc
      #
      # == Examples
      #
      #   should_accept_nested_attributes_for :tasks
      #   should_accept_nested_attributes_for :tasks, :allow_destroy => true
      #
      # :accept and :reject takes objects that are verified against the proc. So
      # having a model:
      #
      #   class Projects < ActiveRecord::Base
      #     has_many :tasks
      #     accepts_nested_attributes_for :tasks, :reject_if => proc { |a| a[:name].blank? }
      #   end
      #
      # You can have the following specs:
      #
      #   should_accept_nested_attributes_for :tasks, :reject => { :name => '' }        # Passes
      #   should_accept_nested_attributes_for :tasks, :accept => { :name => 'My task' } # Passes
      #
      #   should_accept_nested_attributes_for :tasks, :accept => { :name => 'My task' },
      #                                               :reject => { :name => '' }        # Passes
      #
      #   should_accept_nested_attributes_for :tasks, :accept => { :name => '' }        # Fail
      #   should_accept_nested_attributes_for :tasks, :reject => { :name => 'My task' } # Fail
      #
      # You can also give arrays to :accept and :reject to verify multiple attributes.
      #
      def accept_nested_attributes_for(*args, &block)
        AcceptNestedAttributesForMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
