# Remarkable core module
module Remarkable
  # A module that keeps all matchers added. This is useful because it allows
  # to include matchers in Test::Unit as well.
  module Matchers; end

  # Helper that includes required Remarkable modules into the given klass.
  #
  # If the module to be included responds to :after_include, it's called with the
  # target as argument.
  #
  def self.include_matchers!(base, target)
    target.send :extend, Remarkable::Pending
    target.send :extend, Remarkable::Macros

    if defined?(base::Matchers)
      target.send :include, base::Matchers

      Remarkable::Matchers.send :extend, base::Matchers
      Remarkable::Matchers.send :include, base::Matchers
    end

    if base.respond_to?(:after_include)
      base.after_include(target)
    end
  end
end
