# frozen_string_literal: true

module Kafka
  module Events
    class KafkaMessage < Dry::Struct
      attribute :value, Types::Hash
      attribute :topic, Types::EventTopic
      attribute? :headers, KafkaHeaders::Type
      attribute? :partition, Types::Integer
      attribute? :partition_key, Types::Coercible::String
      attribute? :key, Types::Coercible::String
      attribute? :timestamp, Types::Integer || Types::Time

      # Convert to WaterDrop message
      # @example
      #  message = KafkaMessage.new(event)
      #  message.to_waterdrop
      # # => { payload:, key:, topic:, headers: }
      # @return [Hash]
      def to_waterdrop
        {
          payload: value.to_json,
          key: key,
          topic: topic,
          headers: headers.to_h,
          partition: partition,
          partition_key: partition_key,
          timestamp: timestamp
        }.compact
      end
    end
  end
end
