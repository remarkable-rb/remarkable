module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateAssociatedMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :associations, :as => :association, :block => true

        optional :message
        optional :builder, :block => true

        collection_assertions :find_association?, :is_valid?
        default_options :message => :invalid

        protected

          def find_association?
            reflection = @subject.class.reflect_on_association(@association)

            raise ScriptError, "Could not find association #{@association} on #{subject_class}." unless reflection

            associated_object = if builder = @options[:builder] || @block
              builder.call(@subject)
            elsif [:belongs_to, :has_one].include?(reflection.macro)
              @subject.send(:"build_#{@association}") rescue nil
            else
              @subject.send(@association).build rescue nil
            end

            raise ScriptError, "The association object #{@association} could not be built. You can give me " <<
                               ":builder as option or a block which returns an association." unless associated_object

            raise ScriptError, "The associated object #{@association} is not invalid. You can give me " <<
                               ":builder as option or a block which returns an invalid association." if associated_object.save

            return true
          end

          def is_valid?
            return false if @subject.valid?

            error_message_to_expect = error_message_from_model(@subject, :base, @options[:message])

            # In Rails 2.1.2, the error on association returns a symbol (:invalid)
            # instead of the message, so we check this case here.
            @subject.errors.on(@association) == @options[:message] ||
            assert_contains(@subject.errors.on(@association), error_message_to_expect)
          end
      end

      # Ensures that the model is invalid if one of the associations given is
      # invalid. It tries to build the association automatically. In has_one
      # and belongs_to cases, it will build it like this:
      #
      #   @model.build_association
      #   @project.build_manager
      #
      # In has_many and has_and_belongs_to_many to cases it will build it like
      # this:
      #
      #   @model.association.build
      #   @project.tasks.build
      #
      # The object returned MUST be invalid and it's likely the case, since the
      # associated object is empty when calling build. However, if the associated
      # object has to be manipulated to be invalid, you will have to give :builder
      # as option or a block to manipulate it:
      #
      #   should_validate_associated(:tasks) do |project|
      #     project.tasks.build(:captcha => 'i_am_a_bot')
      #   end
      #
      # In the case above, the associated object task is only invalid when the
      # captcha attribute is set. So we give a block to the matcher that tell
      # exactly how to build an invalid object.
      #
      # The example above can also be written as:
      #
      #   should_validate_associated :tasks, :builder => proc{ |p| p.tasks.build(:captcha => 'i_am_a_bot') }
      #
      # == Options
      #
      # * <tt>:builder</tt> - a proc to build the association
      #
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # == Examples
      #
      #   should_validate_associated :tasks
      #   should_validate_associated :tasks, :builder => proc{ |p| p.tasks.build(:captcha => 'i_am_a_bot') }
      #
      #   it { should validate_associated(:tasks) }
      #   it { should validate_associated(:tasks, :builder => proc{ |p| p.tasks.build(:captcha => 'i_am_a_bot') }) }
      #
      def validate_associated(*args, &block)
        ValidateAssociatedMatcher.new(*args, &block).spec(self)
      end
    end
  end
end
