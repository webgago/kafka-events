# frozen_string_literal: true

module Kafka
  module Events
    class Base < Dry::Struct
      extend ClassInterface
      extend DSLInterface
      extend BuilderInterface

      abstract!

      attribute? :key, Types::Strict::String.optional.default(nil)
      attribute? :partition, Types::Strict::Integer.optional.default(nil)
      private :key, :partition

      # @return [Kafka::Events::KafkaMessage]
      def to_kafka # rubocop:disable Metrics/AbcSize
        KafkaMessage.new(
          {
            value: payload.to_h.merge(type: type),
            headers: headers.to_h,
            topic: topic,
            key: key || self.class.key.call(self)&.to_s,
            # Returns partition number if partition == nil
            # You can define custom partitioner by
            #   Event.partitioner { |event| ... }
            # if you want to use kafka's default partitioner, return -1
            partition: partition || self.class.partitioner.call(self).then { |p| p.negative? ? nil : p }
          }.compact
        )
      end

      # @return [String]
      def type
        self.class.type
      end

      # @return [Class<Kafka::Events::Service>]
      def service
        self.class.service
      end

      def method_missing(name, *args)
        payload.send(name, *args)
      end

      def respond_to_missing?(name, include_private = false)
        payload.respond_to?(name, include_private) || super
      end
    end
  end
end
