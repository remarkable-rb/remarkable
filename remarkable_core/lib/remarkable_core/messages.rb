module Remarkable
  module Messages

    # Provides a default description message. Overwrite it if needed.
    def description(options={})
      options = {
        :scope => matcher_i18n_scope
      }.merge(options)

      Remarkable.t 'description', options
    end

    # Provides a default expectation message. Overwrite it if needed.
    def expectation(options={})
      options = {
        :scope => matcher_i18n_scope,
        :subject_name => subject_name,
        :subject_inspect => @subject.inspect
      }.merge(options)

      Remarkable.t 'expectation', options
    end

    # Provides a default failure message. Overwrite it if needed.
    def failure_message
      Remarkable.t 'remarkable.core.failure_message', :expectation => expectation, :missing => @missing
    end

    # Provides a default negative failure message. Overwrite it if needed.
    def negative_failure_message
      Remarkable.t 'remarkable.core.negative_failure_message', :expectation => expectation
    end

  end
end
