module Remarkable
  module ActiveRecord
    module Matchers
      class HaveDefaultScopeMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments
        assertions :options_match?

        optionals :conditions, :include, :joins, :limit, :offset, :order, :select,
                  :readonly, :group, :having, :from, :lock

        protected

          def options_match?
            default_scope.include?(@options)
          end

          def default_scope
            @default_scope ||= if @subject
              scopes = subject_class.default_scoping || []
              scopes.map!{ |s| s[:find] }
            else
              []
            end
          end

          def interpolation_options
            { :options => @options.inspect, :actual => default_scope.inspect }
          end

      end

      # Ensures that the model has a default scope with the given options.
      #
      # == Options
      #
      # All options that the default scope would pass on to find: :conditions,
      # :include, :joins, :limit, :offset, :order, :select, :readonly, :group,
      # :having, :from, :lock.
      #
      # == Examples
      #
      #   it { should have_default_scope(:conditions => {:visible => true}) }
      #   it { should have_default_scope.conditions(:visible => true) }
      #
      # Passes for:
      #
      #   default_scope :conditions => { :visible => true }
      #
      # If you set two different default scopes, you have to spec them
      # separatedly. Given the scopes:
      #
      #   default_scope :conditions => { :visible => true }
      #   default_scope :conditions => { :published => true }
      #
      # Then we have the matchers:
      #
      #   should_have_default_scope :conditions => { :visible => true }   # Passes
      #   should_have_default_scope :conditions => { :published => true } # Passes
      #
      #   should_have_default_scope :conditions => { :published => true,
      #                                               :visible => true }  # Fails
      #
      def have_default_scope(*args, &block)
        HaveDefaultScopeMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
