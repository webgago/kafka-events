# frozen_string_literal: true

module Kafka
  module Events
    class Service
      extend Dry::Initializer
      extend Kafka::Events::Helpers

      # @!attribute [r] event
      #   @return [Kafka::Events::Base] input event
      param :event, Types.Instance(Kafka::Events::Base)

      # @!attribute [r] events
      #  @return [Array<Kafka::Events::Base>] output events produced by service
      option :events, Types::Array.of(Types.Instance(Kafka::Events::Base)), default: -> { [] }

      def call; end

      protected

      # Append event to #events.
      # @example
      #   produce(TestEvent, foo: 1, bar: "baz", headers: { special: true })
      #   produce(TestEvent[foo: 1, bar: "baz"])
      #
      # @param [Class<Kafka::Event::Base> | Kafka::Event::Builder | Kafka::Event::Base] event or event class
      # @param [Hash] headers
      # @param [Hash] **payload
      # @return [Array<Kafka::Events::Base>] +events+ with new event
      def produce(event, headers: {}, **payload)
        return events << event if event.is_a?(Kafka::Events::Base)
        return unless headers.present? || payload.present?

        events << self.event.produce(event, headers: headers, **payload)
      end
    end
  end
end
