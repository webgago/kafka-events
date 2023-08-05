# frozen_string_literal: true

module Kafka
  module Events
    class Config < Dry::Validation::Config
      setting :base_contract_class
    end
  end
end
