module Remarkable
  module Pending

    def self.extended(base) #:nodoc:
      base.instance_eval do
        alias :it :example
        alias :specify :example
      end
    end

    # Adds a pending block to your specs.
    #
    # == Examples
    #
    #   pending 'create manager resource' do
    #     should_have_one :manager
    #     should_validate_associated :manager
    #   end
    #
    # By default, it executes the examples inside the pending block. So as soon
    # as you add the has_one :manager relationship to your model, your specs
    # will say that this was already fixed and there is no need to be treated
    # as pending. To disable this behavior, you can give :execute => false:
    #
    #   pending 'create manager resource', :execute => false
    #
    def pending(*args, &block)
      options = { :execute => true }.merge(args.extract_options!)

      @_pending_group = true
      @_pending_group_description = args.first || "TODO"
      @_pending_group_execute = options.delete(:execute)

      self.instance_eval(&block)

      @_pending_group = false
      @_pending_group_description = nil
      @_pending_group_execute = nil
    end

    protected

      def example(description=nil, &block) #:nodoc:
        if @_pending_group
          pending_caller      = caller.detect{ |c| c !~ /method_missing'/ }
          pending_description = @_pending_group_description

          pending_block = if block_given? && @_pending_group_execute
            proc{ pending(pending_description, &block) }
          else
            proc{ pending(pending_description) }
          end

          super(description, {}, pending_caller, &pending_block)
        else
          super(description, &block)
        end
      end

  end
end
