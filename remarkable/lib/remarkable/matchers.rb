# Remarkable core module
module Remarkable
  # A module that keeps all matchers added. This is useful because it allows
  # to include matchers in Test::Unit as well.
  module Matchers; end

  # Helper that includes required Remarkable modules into the given klass.
  def self.include_matchers!(base, klass)
    # Add Remarkable macros core module
    klass.send :extend, Remarkable::Macros

    if defined?(base::Matchers)
      klass.send :include, base::Matchers

      Remarkable::Matchers.send :extend, base::Matchers
      Remarkable::Matchers.send :include, base::Matchers
    end
  end
end
