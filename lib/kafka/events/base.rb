# frozen_string_literal: true

module Kafka
  module Events
    class Base < Dry::Struct
      extend ClassInterface
      extend DSLInterface
      extend BuilderInterface

      abstract!

      # @return [Hash[Symbol, Object]]
      def to_h
        {
          value: payload.to_h.merge(type: type),
          headers: headers.to_h,
          topic: topic,
          key: key,
          partition: partition
        }.compact
      end

      # @return [Kafka::Events::KafkaMessage]
      def to_kafka
        KafkaMessage.new(to_h)
      end

      # Returns partition number
      # You can define custom partitioner by
      #   Event.partitioner { |event| ... }
      # if you want to use kafka's default partitioner, return -1
      #
      # @return [Integer, nil]
      def partition
        self.class.partitioner.call(self).then { |p| p.negative? ? nil : p }
      end

      def topic
        self.class.topic
      end

      def type
        self.class.type
      end

      def key
        self.class.key.call(self)&.to_s
      end

      # @return [Array<Kafka::Events::Base>] resulting events
      def call
        service = self.class.service.new(self)
        service.call
        service.events
      end

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
