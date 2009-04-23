module Remarkable
  module ActiveRecord
    # Holds ActiveRecord matchers.
    #
    # == Validations matchers
    #
    # Remarkable supports all ActiveRecord validations, and the only options
    # not supported in those matchers is the :on options. So whenever you have
    # to test that a validation runs on update, you have to do reproduce the
    # state in your tests:
    #
    #   describe Project do
    #     describe 'validations on create' do
    #       should_validate_presence_of :title
    #     end
    #
    #     describe 'validations on update' do
    #       subject { Post.create!(@valid_attributes) }
    #       should_validate_presence_of :updated_at
    #     end
    #   end
    #
    # Another behavior in validations is the :message option. Whenever you change
    # the message in your model, it must be given in your tests too:
    #
    #   class Post < ActiveRecord::Base
    #     validates_presence_of :title, :message => 'must be filled'
    #   end
    #
    #   describe Post do
    #     should_validate_presence_of :title #=> fails
    #     should_validate_presence_of :title, :message => 'must be filled'
    #   end
    #
    # However, if you change the title using the I18n API, you don't need to
    # specify the message in your tests, because it's retrieved properly.
    #
    module Matchers
      class ValidatePresenceOfMatcher < Remarkable::ActiveRecord::Base #:nodoc:
        arguments :collection => :attributes, :as => :attribute
        optional  :message

        collection_assertions :allow_nil?
        default_options :message => :blank, :allow_nil => false
      end

      # Ensures that the model cannot be saved if one of the attributes listed is not present.
      #
      # == Options
      #
      # * <tt>:message</tt> - value the test expects to find in <tt>errors.on(:attribute)</tt>.
      #   Regexp, string or symbol. Default = <tt>I18n.translate('activerecord.errors.messages.blank')</tt>
      #
      # == Examples
      #
      #   should_validate_presence_of :name, :phone_number
      #   it { should validate_presence_of(:name, :phone_number) }
      #
      def validate_presence_of(*args)
        ValidatePresenceOfMatcher.new(*args).spec(self)
      end
    end
  end
end
