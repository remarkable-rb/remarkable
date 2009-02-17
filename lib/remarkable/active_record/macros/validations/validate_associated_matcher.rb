module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateAssociatedMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        undef_method :allow_nil, :allow_nil?, :allow_blank, :allow_blank?

        arguments :associations
        optional :builder

        assertions :build_association?, :valid?

        def description
          "require association #{@associations.to_sentence} to be valid"
        end

        private

        # Try to build the association. First we check if the user sent
        # a builder as proc. An example of proc given could be:
        #
        #   proc { |subject| subject.associations.build }
        #
        # Second we attempt to get a instance variable with the singular name
        # of the association. If not possible, we finally try:
        #
        #   subject.associations.build
        #
        # Our last option is:
        #
        #   subject.build_association
        #
        def build_association?
          @plural             = @association.to_s.pluralize
          @singular           = @plural.singularize
          @association_object = nil

          if @options[:builder].is_a? Proc
            @association_object = @options[:builder].call(@subject)
          elsif !@spec.instance_variable_get("@#{@singular}").nil?
            @association_object = @spec.instance_variable_get("@#{@singular}")
          end

          if plural?
            if @association_object # Append the association if already found
              @subject.send(@plural).send('<<', @association_object)
            elsif @subject.send(@plural).respond_to?(:build)
              @association_object = @subject.send(@plural).send(:build)
            end
          elsif singular?
            if @association_object # Set the association if already found
              @subject.send("#{@singular}=", @association_object)
            elsif @subject.respond_to?("build_#{@singular}")
              @association_object = @subject.send("build_#{@singular}")
            end
          end

          return true if @association_object

          @missing = "cannot build association, tried to find instance variable " +
                     "@#{subject_name.downcase}, then tried @#{subject_name.downcase}.#{@plural}.build " +
                     "and @#{subject_name.downcase}.build_#{@singular} without success."

          @missing << " Please give a proc as optional :builder to build the association." unless @options[:builder].is_a? Proc

          return false
        end

        def valid?
          # Try to save the association
          association_saved = if plural?
            @subject.send(@plural).last.save
          elsif singular?
            @subject.send(@singular).save
          end

          if association_saved
            @missing = "the given association #{@association} cannot be saved with errors"
            return false
          end

          @subject.save

          error_message_to_expect = error_message_from_model(@subject, :base, @options[:message])
          return true if assert_contains(@subject.errors.on(plural? ? @plural : @singular), error_message_to_expect)

          @missing = "#{subject_class} is not invalid when #{@association} is invalid"
          false
        end

        # Before make the assertions, convert the subject into a instance, if
        # it's not already.
        #
        def before_assert
          @subject = get_instance_of(@subject)
        end

        def default_options
          { :message => :invalid }
        end

        def plural?
          @subject.respond_to? @plural
        end

        def singular?
          @subject.respond_to? @singular
        end

        def expectation
          "that #{subject_name} is invalid if #{@association} is invalid"
        end
      end

      # Ensures that the model is invalid if one of the associations given is
      # invalid.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # It tries to build an instance of the association by two ways. Let's
      # suppose a user that has many projects and you want to validate it:
      #
      #   it { should validate_associated(:projects) }
      #
      # The first attempt to build the association would be:
      #
      #   @user.projects.build
      #
      # If not possible, then we try:
      #
      #   @user.build_project
      #
      # Then it tries to save the associated object. If the object can be saved
      # if success (in this case, it allows all attributes as blank), we won't
      # be able to verify the validation and then an error will be raised. In
      # such cases, you should instantiate the association before calling the
      # matcher:
      #
      #   it do
      #     @user = User.new
      #     @project = @user.projects.build
      #     should validate_associated(:projects)
      #   end
      #
      # Or give :builder as option:
      #
      #   should_validate_associated :projects, :builder => proc { |user| user.projects.build }
      #
      # Options:
      # * <tt>:builder</tt> - a proc to build the association.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.invalid')</tt>
      #
      # Example:
      #
      #   it { should validate_associated(:projects, :account) }
      #   it { should validate_associated(:projects, :builder => proc { |user| user.projects.build }) }
      #
      def validate_associated(*attributes)
        ValidateAssociatedMatcher.new(*attributes)
      end
    end
  end
end
