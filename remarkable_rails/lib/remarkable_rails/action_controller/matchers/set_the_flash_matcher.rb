require File.join(File.dirname(__FILE__), 'set_session_matcher') 

module Remarkable
  module ActionController
    module Matchers
      class SetTheFlashMatcher < SetSessionMatcher #:nodoc:

        protected
          def session
            @subject ? (@subject.response.session['flash'] || {}) : {}
          end

          def interpolation_options
            { :flash_inspect => session.symbolize_keys!.inspect }
          end

      end

      # Ensures that a flash message is being set. If you want to check that a
      # flash is not being set, just do:
      #
      #   should_not_set_the_flash :user
      #
      # If you want to assure that a flash is being set to nil, do instead:
      #
      #   should_set_the_flash :user, :to => nil
      #
      # == Options
      #
      # * <tt>:to</tt> - The value to compare the flash key.
      #   It accepts procs and can also be given as a block (see examples below)
      #
      # == Examples
      #
      #   should_set_the_flash
      #   should_not_set_the_flash
      #
      #   should_set_the_flash :to => 'message'
      #   should_set_the_flash :notice, :warn
      #   should_set_the_flash :notice, :to => 'message'
      #   should_set_the_flash :notice, :to => proc{ 'hi ' + users(:first).name }
      #   should_set_the_flash(:notice){ 'hi ' + users(:first).name }
      #
      #   it { should set_the_flash }
      #   it { should set_the_flash.to('message') }
      #   it { should set_the_flash(:notice, :warn) }
      #   it { should set_the_flash(:notice, :to => 'message') }
      #   it { should set_the_flash(:notice, :to => ('hi ' + users(:first).name)) }
      #
      def set_the_flash(*args, &block)
        SetTheFlashMatcher.new(*args, &block).spec(self)
      end

    end
  end
end
