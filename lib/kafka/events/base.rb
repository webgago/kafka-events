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

      # @return [String]
      def topic
        self.class.topic
      end

      # @return [String]
      def type
        self.class.type
      end

      # @return [String, nil]
      def key
        self.class.key.call(self)&.to_s
      end

      # Instantiates a new service, calls it and returns resulting events
      # @example
      #  event.call # => [TestEvent[foo: 1, bar: "baz"]]
      #
      # @return [Array<Kafka::Events::Base>] resulting events
      def call
        service = self.service.new(self)
        service.call
        service.events
      end

      # @return [Class<Kafka::Events::Service>]
      def service
        self.class.service
      end

      # @param [Class<Kafka::Events::Base>] klass
      # @param [Hash] headers
      # @param [Hash] payload
      # @return [Kafka::Events::Base]
      def produce(klass, headers: {}, **payload)
        klass.headers(**headers).create(payload)
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
