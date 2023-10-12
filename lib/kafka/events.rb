# frozen_string_literal: true

require "dry-struct"
require "dry-validation"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/class/attribute"
require "dry/schema/extensions/struct"
require "dry/schema/messages/abstract"
require "dry/schema/message_compiler"
require "dry/schema/message_compiler/visitor_opts"
require "dry/container"

require_relative "events/version"
require_relative "events/errors"
require_relative "events/helpers"
require_relative "events/constants"
require_relative "events/contract"
require_relative "events/types"
require_relative "events/config"
require_relative "events/contract_builder"
require_relative "events/class_interface"
require_relative "events/dsl_interface"
require_relative "events/builder"
require_relative "events/builder_interface"
require_relative "events/kafka_headers"
require_relative "events/kafka_message"
require_relative "events/context"
require_relative "events/base"
require_relative "events/service/class_interface"
require_relative "events/service/validation"
require_relative "events/service"
require_relative "events/job"

module Kafka
  module Events
    extend Dry::Configurable

    module_function

    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end

    Contract.instance_variable_set("@config", config)

    configure do |config|
      config.validate_keys = true
      config.base_contract_class = Contract
    end
  end
end
