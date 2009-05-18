module Remarkable
  module ActiveRecord
    module Matchers
      class ValidateUniquenessOfMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :attributes, :as => :attribute

        optional :message
        optional :scope, :splat => true
        optional :case_sensitive, :allow_nil, :allow_blank, :default => true

        collection_assertions :find_first_object?, :responds_to_scope?, :is_unique?, :case_sensitive?,
                              :valid_with_new_scope?, :allow_nil?, :allow_blank?

        default_options :message => :taken

        before_assert do
          @options[:scope] = [*@options[:scope]].compact if @options[:scope]
        end

        private

          # Tries to find an object in the database. If allow_nil and/or allow_blank
          # is given, we must find a record which is not nil or not blank.
          #
          # We should also ensure that the object retrieved from the database
          # is not the @subject.
          #
          # If any of these attempts fail, an error is raised.
          #
          def find_first_object?
            conditions, message = if @options[:allow_nil]
              [ ["#{@attribute} IS NOT NULL"], " with #{@attribute} not nil" ]
            elsif @options[:allow_blank]
              [ ["#{@attribute} != ''"], " with #{@attribute} not blank" ]
            else
              [ [], "" ]
            end

            unless @subject.new_record?
              primary_key = subject_class.primary_key

              message    << " which is different from the subject record (the object being validated is the same as the one in the database)"
              conditions << "#{subject_class.primary_key} != '#{@subject.send(primary_key)}'"
            end

            options = conditions.empty? ? {} : { :conditions => conditions.join(' AND ') }

            return true if @existing = subject_class.find(:first, options)
            raise ScriptError, "could not find a #{subject_class} record in the database" + message
          end

          # Set subject scope to be equal to the object found.
          #
          def responds_to_scope?
            (@options[:scope] || []).each do |scope|
              setter = :"#{scope}="

              return false, :method => setter unless @subject.respond_to?(setter)
              return false, :method => scope  unless @existing.respond_to?(scope)

              @subject.send(setter, @existing.send(scope))
            end
            true
          end

          # Check if the attribute given is valid and if the validation fails for equal values.
          #
          def is_unique?
            @value = @existing.send(@attribute)
            return bad?(@value)
          end

          # If :case_sensitive is given and it's false, we swap the case of the
          # value used in :is_unique? and see if the test object remains valid.
          #
          # If :case_sensitive is given and it's true, we swap the case of the
          # value used in is_unique? and see if the test object is not valid.
          #
          # This validation will only occur if the test object is a String.
          # 
          def case_sensitive?
            return true unless @value.is_a?(String)
            assert_good_or_bad_if_key(:case_sensitive, @value.swapcase)
          end

          # Now test that the object is valid when changing the scoped attribute.
          #
          def valid_with_new_scope?
            (@options[:scope] || []).each do |scope|
              setter = :"#{scope}="

              previous_scope_value = @subject.send(scope)
              @subject.send(setter, new_value_for_scope(scope))
              return false, :method => scope unless good?(@value)

              @subject.send(setter, previous_scope_value)
            end
            true
          end

          # Change the existing object attribute to nil to run allow nil
          # validations. If we find any problem while updating the @existing
          # record, it's because we can't save nil values in the database. So it
          # passes when :allow_nil is false, but should raise an error when
          # :allow_nil is true
          #
          def allow_nil?
            return true unless @options.key?(:allow_nil)

            begin
              @existing.update_attribute(@attribute, nil)
            rescue ::ActiveRecord::StatementInvalid => e
              raise ScriptError, "You declared that #{@attribute} accepts nil values in validate_uniqueness_of, " <<
                                 "but I cannot save nil values in the database, got: #{e.message}" if @options[:allow_nil]
              return true
            end

            super
          end

          # Change the existing object attribute to blank to run allow blank
          # validation. It uses the same logic as :allow_nil.
          #
          def allow_blank?
            return true unless @options.key?(:allow_blank)

            begin
              @existing.update_attribute(@attribute, '')
            rescue ::ActiveRecord::StatementInvalid => e
              raise ScriptError, "You declared that #{@attribute} accepts blank values in validate_uniqueness_of, " <<
                                 "but I cannot save blank values in the database, got: #{e.message}" if @options[:allow_blank]
              return true
            end

            super
          end

          # Returns a value to be used as new scope. It deals with four different
          # cases: date, time, boolean and stringfiable (everything that can be
          # converted to a string and the next value makes sense)
          #
          def new_value_for_scope(scope)
            column_type = if @existing.respond_to?(:column_for_attribute)
              @existing.column_for_attribute(scope)
            else
              nil
            end

            case column_type.type
              when :int, :integer, :float, :decimal
                new_value_for_stringfiable_scope(scope)
              when :datetime, :timestamp, :time
                Time.now + 10000
              when :date
                Date.today + 100
              when :boolean
                !@existing.send(scope)
              else
                new_value_for_stringfiable_scope(scope)
            end
          end

          # Returns a value to be used as scope by generating a range of values
          # and searching for them in the database.
          #
          def new_value_for_stringfiable_scope(scope)
            values = [(@existing.send(scope) || 999).next.to_s]

            # Generate a range of values to search in the database
            100.times do
              values << values.last.next
            end
            conditions = { scope => values, @attribute => @value }

            # Get values from the database, get the scope attribute and map them to string.
            db_values = subject_class.find(:all, :conditions => conditions, :select => scope)
            db_values.map!{ |r| r.send(scope).to_s }

            if value_to_return = (values - db_values).first
              value_to_return
            else
              raise ScriptError, "Tried to find an unique scope value for #{scope} but I could not. " << 
                                 "The conditions hash was #{conditions.inspect} and it returned all records."
            end
          end
      end

      # Ensures that the model cannot be saved if one of the attributes listed
      # is not unique.
      #
      # Requires an existing record in the database. If you supply :allow_nil as
      # option, you need to have in the database a record which is not nil in the
      # given attributes. The same is required for allow_blank option.
      #
      # Notice that the record being validate should not be the same as in the
      # database. In other words, you can't do this:
      #
      #   subject { Post.create!(@valid_attributes) }
      #   should_validate_uniqueness_of :title
      #
      # But don't worry, if you eventually do that, a helpful error message
      # will be raised.
      #
      # == Options
      #
      # * <tt>:scope</tt> - field(s) to scope the uniqueness to.
      # * <tt>:case_sensitive</tt> - the matcher look for an exact match.
      # * <tt>:allow_nil</tt> - when supplied, validates if it allows nil or not.
      # * <tt>:allow_blank</tt> - when supplied, validates if it allows blank or not.
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol.  Default = <tt>I18n.translate('activerecord.errors.messages.taken')</tt>
      #
      # == Examples
      #
      #   it { should validate_uniqueness_of(:keyword, :username) }
      #   it { should validate_uniqueness_of(:email, :scope => :name, :case_sensitive => false) }
      #   it { should validate_uniqueness_of(:address, :scope => [:first_name, :last_name]) }
      #
      #   should_validate_uniqueness_of :keyword, :username
      #   should_validate_uniqueness_of :email, :scope => :name, :case_sensitive => false
      #   should_validate_uniqueness_of :address, :scope => [:first_name, :last_name]
      #
      #   should_validate_uniqueness_of :email do |m|
      #     m.scope = name
      #     m.case_sensitive = false
      #   end
      #
      def validate_uniqueness_of(*attributes, &block)
        ValidateUniquenessOfMatcher.new(*attributes, &block).spec(self)
      end
    end
  end
end
