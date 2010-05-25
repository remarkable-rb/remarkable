module Remarkable
  # Holds the methods required by rspec for each matcher plus a collection of
  # helpers to deal with I18n.
  #
  module Messages

    # Provides a default description message. Overwrite it if needed.
    # By default it uses default i18n options, but without the subjects, which
    # usually are not available when description is called.
    #
    def description(options={})
      options = default_i18n_options.merge(options)

      # Remove subject keys
      options.delete(:subject_name)
      options.delete(:subject_inspect)

      Remarkable.t 'description', options
    end

    # Provides a default failure message. Overwrite it if needed.
    #
    def failure_message_for_should
      Remarkable.t 'remarkable.core.failure_message_for_should', :expectation => @expectation
    end
    alias :failure_message :failure_message_for_should

    # Provides a default negative failure message. Overwrite it if needed.
    #
    def failure_message_for_should_not
      Remarkable.t 'remarkable.core.failure_message_for_should_not', :expectation => @expectation
    end
    alias :negative_failure_message :failure_message_for_should_not

    private

      # Returns the matcher scope in I18n.
      #
      # If the matcher is Remarkable::ActiveRecord::Matchers::ValidatePresenceOfMatcher
      # the default scope will be:
      #
      #   'remarkable.active_record.validate_presence_of'
      #
      def matcher_i18n_scope
        @matcher_i18n_scope ||= self.class.name.to_s.
                                gsub(/::Matchers::/, '::').
                                gsub(/::/, '.').
                                gsub(/Matcher$/, '').
                                gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
                                gsub(/([a-z\d])([A-Z])/,'\1_\2').
                                tr("-", "_").
                                downcase
      end

      # Matcher i18n options used in description, failure_message and
      # negative_failure_message. It provides by default the subject_name and
      # the subject_inspect value. But when used with DSL, it provides a whole
      # bunch of options (check dsl/matches.rb for more information).
      #
      def default_i18n_options
        interpolation_options.update(
          :scope => matcher_i18n_scope,
          :subject_name => subject_name,
          :subject_inspect => @subject.inspect
        )
      end

      # Method to be overwritten if user wants to provide more interpolation
      # options to I18n.
      #
      def interpolation_options
        {}
      end

      # Returns the not word from I18n API.
      #
      def not_word
        Remarkable.t('remarkable.core.not', :default => 'not') + " "
      end

      # Converts an array to a sentence
      #
      def array_to_sentence(array, inspect=false, empty_default='')
        words_connector     = Remarkable.t 'remarkable.core.helpers.words_connector'
        two_words_connector = Remarkable.t 'remarkable.core.helpers.two_words_connector'
        last_word_connector = Remarkable.t 'remarkable.core.helpers.last_word_connector'

        array = array.map { |i| i.inspect } if inspect

        case array.length
          when 0
            empty_default
          when 1
            array[0].to_s
          when 2
            "#{array[0]}#{two_words_connector}#{array[1]}"
          else
            "#{array[0...-1].join(words_connector)}#{last_word_connector}#{array[-1]}"
        end
      end

  end
end
