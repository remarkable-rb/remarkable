module Remarkable
  # Allows Remarkable matchers to work on the negative way. Your matcher has to
  # follow some conventions to allow this to work by default.
  #
  # In negative cases, expectations can also be found under negative_expectations
  # keys, falling back to expectations. This allows to set customized failure
  # messages.
  #
  module Negative
    def matches?(subject)
      @negative ||= false
      super
    end

    def does_not_match?(subject)
      @negative = true
      !matches?(subject)
    end

    def negative?
      @negative
    end
  end
end
