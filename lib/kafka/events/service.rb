# frozen_string_literal: true

module Kafka
  module Events
    class Service
      extend Dry::Initializer
      extend Kafka::Events::Helpers
      extend ClassInterface

      def self.inherited(subclass)
        subclass.prepend(Validation) unless subclass < Validation
        super
      end

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
        return if event.nil?

        event = create_event(event, headers: headers, **payload)
        events << event
      end

      # @param [Class<Kafka::Events::Base> | Kafka::Events::Base] event
      # @option [Hash] headers
      # @option [Hash] **payload
      def create_event(event, headers: {}, **payload)
        if event.is_a?(Class) && event < Kafka::Events::Base
          event.headers(headers).create(payload)
        elsif event.is_a?(Kafka::Events::Base)
          event
        else
          raise ArgumentError, "Invalid event: #{event.inspect}"
        end
      end
    end
  end
end
