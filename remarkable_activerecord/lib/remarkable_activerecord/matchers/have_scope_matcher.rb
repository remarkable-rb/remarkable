module Remarkable
  module ActiveRecord
    module Matchers
      class HaveScopeMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :scope_name
        assertions :is_scope?, :options_match?

        optionals :with, :splat => true
        optionals :conditions, :include, :joins, :limit, :offset, :order, :select,
                  :readonly, :group, :having, :from, :lock

        protected

          def is_scope?
            @scope_object = if @options[:with]
              if @options[:with].is_a?(Array)
                subject_class.send(@scope_name, *@options[:with])
              else
                subject_class.send(@scope_name, @options[:with])
              end
            else
              subject_class.send(@scope_name)
            end

            @scope_object.class == ::ActiveRecord::NamedScope::Scope
          end

          def options_match?
            @options.empty? || @scope_object.proxy_options == @options.except(:with)
          end

          def interpolation_options
            { :options => @options.except(:with).inspect,
              :actual  => (@scope_object ? @scope_object.proxy_options.inspect : '{}')
            }
          end

      end

      # Ensures that the model has a method named scope that returns a NamedScope
      # object with the supplied proxy options.
      #
      # == Options
      #
      # * <tt>with</tt> - Options to be sent to the named scope
      #
      # All options that the named scope would pass on to find: :conditions,
      # :include, :joins, :limit, :offset, :order, :select, :readonly, :group,
      # :having, :from, :lock.
      #
      # == Examples
      # 
      #   it { should have_scope(:visible, :conditions => {:visible => true}) }
      #   it { should have_scope(:visible).conditions(:visible => true) }
      #
      # Passes for
      #
      #   named_scope :visible, :conditions => {:visible => true}
      #
      # Or for
      #
      #   def self.visible
      #     scoped(:conditions => {:visible => true})
      #   end
      #
      # You can test lambdas or methods that return ActiveRecord#scoped calls:
      #
      #   it { should have_scope(:recent, :with => 5) }
      #   it { should have_scope(:recent, :with => 1) }
      #
      # Passes for
      #
      #   named_scope :recent, lambda {|c| {:limit => c}}
      #
      # Or for
      #
      #   def self.recent(c)
      #     scoped(:limit => c)
      #   end
      #
      def have_scope(*args)
        HaveScopeMatcher.new(*args).spec(self)
      end
      alias :have_named_scope :have_scope

    end
  end
end
