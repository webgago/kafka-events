# frozen_string_literal: true

module Kafka
  module Events
    # Builds a contract for a Kafka::Events::Base subclass
    # based on the schema
    # @api private
    module ContractBuilder
      module_function

      # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      # @return [Class]
      # @raise [ArgumentError] if the schema is missing one of required keys: :headers, :value, :topic, :type
      def build(schema, &rules)
        name_key_map = schema.type.name_key_map
        payload_schema = schema(:payload, name_key_map)
        headers_schema = schema(:headers, name_key_map)

        Class.new(Events.config.base_contract_class) do
          json do
            required(:type).filled(Types::EventType)
            required(:payload).hash(payload_schema)
            required(:headers).hash(headers_schema)
            required(:topic).filled(Types::EventTopic)
            optional(:key).maybe(:string)
            optional(:partition).maybe(:integer)
          end

          instance_exec(&rules) if rules
        end
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      def schema(key, name_key_map)
        name_key_map.fetch(key).type.schema
      rescue KeyError
        Dry::Schema.Params
      end
    end
  end
end
