require 'remarkable/core/dsl/assertions'
require 'remarkable/core/dsl/optionals'
require 'remarkable/core/dsl/callbacks'

module Remarkable
  # The DSL module is responsable for all Remarkable convenience methods.
  # It has three main submodules:
  #
  #   * <tt>Assertions</tt> - adds a class methods to define matcher initialization and assertions,
  #                           allowing matches? to be hidden from the matcher developer and dealing
  #                           with I18n in the expectations messages;
  #
  #   * <tt>Callbacks</tt> - provides API for after_initialize and before_assert callbacks;
  #
  #   * <tt>Optionals</tt> - add an optionals DSL, which is also used for the auto configuring blocks
  #                          and dynamic descriptions.
  #
  module DSL
    ATTR_READERS = [
      :matcher_arguments,
      :matcher_optionals,
      :matcher_optionals_splat,
      :matcher_optionals_block,
      :matcher_single_assertions,
      :matcher_collection_assertions,
      :before_assert_callbacks,
      :after_initialize_callbacks
    ] unless self.const_defined?(:ATTR_READERS)

    def self.extended(base) #:nodoc:
      base.send :include, Assertions
      base.send :include, Callbacks
      base.send :include, Optionals

      # Initialize matcher_arguments hash with names as an empty array
      base.instance_variable_set('@matcher_arguments', { :names => [] })
    end

    # Make Remarkable::Base DSL inheritable.
    #
    def inherited(base) #:nodoc:
      base.class_eval do
        class << self
          attr_reader *ATTR_READERS
        end
      end

      ATTR_READERS.each do |attr|
        current_value = self.instance_variable_get("@#{attr}")
        base.instance_variable_set("@#{attr}", current_value ? current_value.dup : [])
      end
    end
  end
end
