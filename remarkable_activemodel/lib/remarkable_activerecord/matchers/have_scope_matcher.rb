module Remarkable
  module ActiveRecord
    module Matchers
      class HaveScopeMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :scope_name
        assertions :is_scope?, :options_match?

        optionals :with, :splat => true
        
        # Chained scopes taken from: http://m.onkey.org/2010/1/22/active-record-query-interface
        optionals :where, :having, :select, :group, :order, :limit, :offset, :joins, :includes, :lock, :readonly, :from

        protected

          def is_scope?
            @scope_object = if @options.key?(:with)
              @options[:with] = [ @options[:with] ] unless Array === @options[:with]
              subject_class.send(@scope_name, *@options[:with])
            else
              subject_class.send(@scope_name)
            end

            @scope_object.class == ::ActiveRecord::Relation && @scope_object.arel 
          end

          def options_match?
            @options.empty? || @scope_object.arel == arel(subject_class, @options.except(:with))
          end

          def interpolation_options
            { 
              :options => (subject_class.respond_to?(:scoped) ? arel(subject_class, @options.except(:with)).to_sql : '{}'),
              :actual  => (@scope_object ? @scope_object.arel.to_sql : '{}')
            }
          end

        private
          def arel(model, scopes = nil)
            return model.scoped unless scopes
            scopes.inject(model.scoped) do |chain, (cond, option)|
              chain.send(cond, option)
            end.arel
          end

      end

      # Ensures that the model has a named scope that returns an Relation object capable
      # of building into relational algebra. 
      #
      # == Options
      #
      # * <tt>with</tt> - Options to be sent to the named scope
      #
      # All options that the named scope would pass on to find: :conditions,
      # :include, :joins, :limit, :offset, :order, :select, :readonly, :group,
      # :having, :from, :lock.
      #
      # Matching is done by constructing the Arel objects and testing for equality.
      #
      # == Examples
      # 
      #   it { should have_scope(:visible, :conditions => {:visible => true}) }
      #   it { should have_scope(:visible).conditions(:visible => true) }
      #
      # Passes for
      #
      #   scope :visible, :conditions => {:visible => true}
      #
      # Or for
      #
      #   scope :visible, lambda { { :conditions => true } }
      #
      # Or for
      #
      #   def self.visible
      #     scoped(:conditions => {:visible => true})
      #   end
      #
      #
      # You can test lambdas or methods that return ActiveRecord#scoped calls by fixing
      # a defined parameter.
      #
      #   it { should have_scope(:recent, :with => 5) }
      #   it { should have_scope(:recent, :with => 1) }
      #
      # Passes for
      #
      #   scope :recent, lambda {|c| {:limit => c}}
      #
      # Or for
      #
      #   def self.recent(c)
      #     scoped(:limit => c)
      #   end
      #
      def have_scope(*args, &block)
        HaveScopeMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
