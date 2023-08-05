# frozen_string_literal: true

module Kafka
  module Events
    class KafkaMessage < Dry::Struct
      attribute :value, Types::Hash
      attribute :topic, Types::EventTopic
      attribute :headers, KafkaHeaders::Type
      attribute :partition, Types::Integer.default(-1)
      attribute? :key, Types::Coercible::String.optional

      # Convert to WaterDrop message
      # @example
      #  message = KafkaMessage.new(event)
      #  message.to_waterdrop
      # # => { payload:, key:, topic:, headers: }
      # @return [Hash]
      def to_waterdrop
        {
          payload: value.to_json,
          key: key.presence || SecureRandom.uuid,
          topic: topic,
          headers: headers.to_h,
          partition: partition
        }
      end
    end
  end
end
