# frozen_string_literal: true

module Kafka
  module Events
    module Constants
      DEFAULT_MESSAGES_ROOT = "kafka_events"

      DEFAULT_MESSAGES_PATH = Pathname(__dir__).join("../../../config/errors.yml").realpath.freeze
    end
  end
end
