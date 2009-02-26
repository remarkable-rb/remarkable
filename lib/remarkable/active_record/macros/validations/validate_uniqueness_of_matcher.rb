module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateUniquenessOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        arguments :attributes
        optional :case_sensitive, :default => true

        assertions :find_first_object?, :have_attribute?, :case_sensitive?,
                   :valid_when_changing_scoped_attribute?, :find_nil_object?,
                   :allow_nil?, :find_blank_object?, :allow_blank?

        def scope(scope)
          @options[:scope] = [*scope].compact
          self
        end

        # TODO Deprecate this
        #
        def scoped_to(scoped)
          warn "[DEPRECATION] scoped_to is deprecated. Use only scope instead."
          scope(scoped)
        end

        def description
          message = "require unique "

          if @options.key? :case_sensitive
            message << (@options[:case_sensitive] ? 'case sensitive ' : 'case insensitive ')
          end

          message << "value for #{@attributes.to_sentence}"
          message << " scoped to #{@options[:scope].to_sentence}" unless @options[:scope].empty?
          message
        end

        private

        # Before make the assertions, convert the subject into a instance, if
        # it's not already.
        #
        def before_assert
          @subject = get_instance_of(@subject)
        end

        def default_options
          { :message => :taken }
        end

        def after_initialize
          if @options[:scoped_to] # TODO Deprecate scoped_to
            warn "[DEPRECATION] :scoped_to is deprecated in should_validate_uniqueness_of. Use :scope instead."
            @options[:scope] = [*@options.delete(:scoped_to)].compact
          else
            @options[:scope] = [*@options[:scope]].compact
          end
        end

        # Tries to find an object in the database.
        #
        # If allow_nil and/or allow_blank is given, we must find a record which
        # is not nil or not blank.
        #
        # If any of these attempts fail, the validation fail.
        #
        def find_first_object?
          if @options[:allow_nil]
            return true if @existing = subject_class.find(:first, :conditions => "#{@attribute} IS NOT NULL")
            @missing = "can't find #{subject_class} with #{@attribute} not nil"
          elsif @options[:allow_blank]
            return true if @existing = subject_class.find(:first, :conditions => "#{@attribute} != ''")
            @missing = "can't find #{subject_class} with #{@attribute} not blank"
          else
            return true if @existing = subject_class.find(:first)
            @missing = "can't find first #{subject_class}"
          end

          false
        end

        # Tries to find an object where the given attribute is nil.
        # This is required to test if the validation allows nil.
        #
        def find_nil_object?
          return true unless @options.key? :allow_nil
          return true if subject_class.find(:first, :conditions => "#{@attribute} IS NULL")

          @missing = "can't find #{subject_class} with #{@attribute} nil"
          false
        end

        # Tries to find an object where the given attribute is blank.
        # This is required to test if the validation allows blank.
        #
        def find_blank_object?
          return true unless @options.key? :allow_blank
          return true if subject_class.find(:first, :conditions => "#{@attribute} = ''")

          @missing = "can't find #{subject_class} with #{@attribute} blank"
          false
        end

        # Check if the attribute given is valid and if the validation fails
        # for equal values.
        #
        def have_attribute?
          @value = @existing.send(@attribute)

          # Sets scope to be equal to the object found
          #
          @options[:scope].each do |s|
            unless @subject.respond_to?(:"#{s}=")
              @missing = "#{subject_name} doesn't seem to have a #{s} attribute."
              return false
            end
            @subject.send("#{s}=", @existing.send(s))
          end

          return true if bad?(@value)

          @missing = "not require unique value for #{@attribute}"
          @missing << " scoped to #{@options[:scope].to_sentence}" unless @options[:scope].empty?
          return false
        end

        # If :case_sensitive is given and it's false, we swap the case of the
        # value used in have_attribute? and see if the test object remains valid.
        #
        # If :case_sensitive is given and it's true, we swap the case of the
        # value used in have_attribute? and see if the test object is not valid.
        #
        # This validation will only occur if the test object is a String.
        # 
        def case_sensitive?
          return true unless @value.is_a?(String)
          
          message = "case sensitive when attribute is #{@attribute}"
          assert_good_or_bad_if_key(:case_sensitive, @value.swapcase, message)
        end

        # Now test that the object is valid when changing the scoped attribute

        def valid_when_changing_scoped_attribute?
          @options[:scope].each do |s|
            # Assume the scope is a foreign key if the field is nil
            @subject.send("#{s}=", new_value_for_scope(s))
            unless good?(@value)
              @missing = "#{subject_name} is not valid when changing the scoped attribute for #{s}"
              return false
            end
          end
          true
        end

        # Returns the value used in valid_when_changing_scoped_attribute.
        # TODO: There is a chance that we could change the scoped field
        # to a value that's already taken. An alternative implementation
        # could actually find all values for scope and create a unique one.
        #
        def new_value_for_scope(scope)
          (@existing.send(scope) || 999).next
        end

        def expectation
          message = "that the #{subject_name} can be saved if "

          if @options.key? :case_sensitive
            message << (@options[:case_sensitive] ? 'case sensitive ' : 'case insensitive ')
          end

          message << @attribute.to_s
          message << " scoped to #{@options[:scope].to_sentence}" unless @options[:scope].empty?
          message << " is unique"
        end
      end

      # Ensures that the model cannot be saved if one of the attributes listed
      # is not unique.
      #
      # Requires an existing record in the database. If you supply :allow_nil as
      # option, you need to have in the database a record with the given attribute
      # nil and another with the given attribute not nil. The same is required for
      # allow_blank option.
      #
      # If an instance variable has been created in the setup named after the
      # model being tested, then this method will use that.  Otherwise, it will
      # create a new instance to test against.
      #
      # Options:
      #
      # * <tt>:scope</tt> - field(s) to scope the uniqueness to.
      # * <tt>:case_sensitive</tt> - the matcher look for an exact match.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.taken')</tt>
      #
      # Examples:
      #
      #   it { should validate_uniqueness_of(:keyword, :username) }
      #   it { should validate_uniqueness_of(:name, :message => "O NOES! SOMEONE STOELED YER NAME!") }
      #   it { should validate_uniqueness_of(:email, :scope => :name, :case_sensitive => false) }
      #   it { should validate_uniqueness_of(:address, :scope => [:first_name, :last_name]) }
      #
      def validate_uniqueness_of(*attributes)
        ValidateUniquenessOfMatcher.new(*attributes)
      end
      
      #TODO Deprecate this alias, the deprecation warning is the matcher
      def require_unique_attributes(*attributes)
        warn "[DEPRECATION] should_require_unique_attributes is deprecated. " <<
             "Use should_validate_uniqueness_of instead."
        validate_uniqueness_of(*attributes)
      end
    end
  end
end
