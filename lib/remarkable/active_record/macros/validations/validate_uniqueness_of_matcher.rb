module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:
      class ValidateUniquenessOfMatcher < Remarkable::Matcher::Base
        include Remarkable::ActiveRecord::Helpers

        def initialize(*attributes)
          load_options(attributes.extract_options!)
          @attributes = attributes
        end

        def scope(scoped)
          @options[:scope] = [*scoped].compact
          self
        end

        def case_sensitive(value = true)
          @options[:case_sensitive] = value
          self
        end

        # TODO Deprecate this
        #
        def scoped_to(scoped)
          @options[:scope] = [*scoped].compact
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@attributes) do |attribute|
            @attribute = attribute

            find_first_object? && have_attribute? && case_sensitive? &&
            valid_when_changing_scoped_attribute? && find_nil_object? &&
            allow_nil? && find_blank_object? && allow_blank?
          end
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

        # Tries to find an object in the database.
        #
        # If allow_nil and/or allow_blank is given, we must find a record which
        # is not nil or not blank.
        #
        # If any of these attempts fail, the validation fail.
        #
        def find_first_object?
          if @options[:allow_nil]
            return true if @existing = model_class.find(:first, :conditions => "#{@attribute} IS NOT NULL")
            @missing = "can't find #{model_class} with #{@attribute} not nil"
          elsif @options[:allow_blank]
            return true if @existing = model_class.find(:first, :conditions => "#{@attribute} != ''")
            @missing = "can't find #{model_class} with #{@attribute} not blank"
          else
            return true if @existing = model_class.find(:first)
            @missing = "can't find first #{model_class}"
          end

          false
        end

        # Tries to find an object where the given attribute is nil.
        # This is required to test if the validation allows nil.
        #
        def find_nil_object?
          return true unless @options.key? :allow_nil
          return true if model_class.find(:first, :conditions => "#{@attribute} IS NULL")

          @missing = "can't find #{model_class} with #{@attribute} nil"
          false
        end

        # Tries to find an object where the given attribute is blank.
        # This is required to test if the validation allows blank.
        #
        def find_blank_object?
          return true unless @options.key? :allow_blank
          return true if model_class.find(:first, :conditions => "#{@attribute} = ''")

          @missing = "can't find #{model_class} with #{@attribute} blank"
          false
        end

        # Check if the attribute given is valid and if the validation fails
        # for equal values.
        #
        def have_attribute?
          @object = model_class.new
          @value = @existing.send(@attribute)

          # Sets scope to be equal to the object found
          #
          @options[:scope].each do |s|
            unless @object.respond_to?(:"#{s}=")
              @missing = "#{model_name} doesn't seem to have a #{s} attribute."
              return false
            end
            @object.send("#{s}=", @existing.send(s))
          end

          return true if bad?(@value)

          @missing = "not require unique value for #{@attribute}"
          @missing << " scoped to #{@options[:scope].to_sentence}" unless @options[:scope].empty?
          return false
        end

        # If :case_sensitive is given and it's true, we swap the case of the
        # value used in have_attribute? and see if the test object is valid.
        #
        # If :case_sensitive is given and it's true, we swap the case of the
        # value used in have_attribute? and see if the test object is not valid.
        #
        def case_sensitive?
          return true unless @options.key? :case_sensitive

          if @options[:case_sensitive]
            return true if good?(@value.swapcase)
            @missing = "#{@attribute} is not case sensitive"
          else
            return true if bad?(@value.swapcase)
            @missing = "#{@attribute} is case sensitive"
          end

          return false
        end

        # Now test that the object is valid when changing the scoped attribute

        def valid_when_changing_scoped_attribute?
          @options[:scope].each do |s|
            # Assume the scope is a foreign key if the field is nil
            @object.send("#{s}=", new_value_for_scope(s))
            unless assert_good_value(@object, @attribute, @value, @options[:message])
              @missing = "#{model_name} is not valid when changing the scoped attribute for #{s}"
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

        def good?(value)
          assert_good_value(@object, @attribute, value, @options[:message])
        end

        def bad?(value)
          assert_bad_value(@object, @attribute, value, @options[:message])
        end

        def load_options(options)
          @options = {
            :message => :taken
          }.merge(options)

          if options[:scoped_to] # TODO Deprecate scoped_to
            @options[:scope] = [*options[:scoped_to]].compact
          else
            @options[:scope] = [*options[:scope]].compact
          end
        end

        def expectation
          message = "that the #{model_name} can be saved if "

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
      # nil and another with the given attribute not nil. The same is require for
      # allow_blank option.
      #
      # Options:
      #
      # * <tt>:scope</tt> - field(s) to scope the uniqueness to.
      # * <tt>:case_sensitive</tt> - the matcher look for an exact match.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp or string.  Default = <tt>I18n.translate('activerecord.errors.messages.taken')</tt>
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
      alias :require_unique_attributes :validate_uniqueness_of
    end
  end
end
