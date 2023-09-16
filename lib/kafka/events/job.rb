# frozen_string_literal: true

module Kafka
  module Events
    class Job
      extend Dry::Initializer

      mattr_accessor :defined_events, default: {}

      option :params, Types::Hash
      option :headers, Types::Hash, default: -> { {} }
      option :type, Types::String.optional, default: -> { params&.fetch(:type, nil) }
      option :klass, Types::Subclass(Base), default: -> { defined_events[type] }

      option :event, Types.Instance(Base), default: -> { klass.headers(headers).create(params) }
      option :producer, Types.Interface(:call), optional: true
      option :service, Types.Instance(Service), default: -> { event&.service&.new(event) }

      # @return [Array<Kafka::Events::KafkaMessage>]
      def perform
        service.call
        service.validate_events!
        service.events.map(&:to_kafka).tap do |kafka_messages|
          produce(kafka_messages)
        end
      end

      private

      def produce(events)
        producer&.call(events)
      end
    end
  end
end
