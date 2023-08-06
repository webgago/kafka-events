# frozen_string_literal: true

module Kafka
  module Events
    class Job
      extend Dry::Initializer

      mattr_accessor :events, default: []

      option :type, Types::String, optional: true
      option :klass, Types::Subclass(Kafka::Events::Base), default: -> { events.find { |e| e.type == type } }
      option :params, Types::Hash
      option :headers, Types::Hash, default: -> { {} }

      option :event, Types.Instance(Base), default: -> { klass.headers(headers).payload(params).build }

      def perform
        validate! event.call
      end

      private

      # @param [Array<Kafka::Events::Base>] produced_events
      def validate!(produced_events)
        actual = produced_events.map(&:class).uniq
        missing, unexpected = missing_and_unexpected_events(actual)

        raise(MustProduceEventError.new(klass, required_events, actual)) if missing.size.positive?
        raise(UnexpectedEventProducedError.new(klass, expected_events, unexpected)) if unexpected.size.positive?

        produced_events
      end

      def missing_and_unexpected_events(actual)
        unexpected = actual - expected_events
        missing = required_events - actual
        [missing, unexpected]
      end

      def expected_events
        @expected_events ||= required_events + optional_events
      end

      def optional_events
        @optional_events ||= event.class.allowed_events.select { |e| e[:optional] }.map { |e| e[:klass] }
      end

      def required_events
        @required_events ||= event.class.allowed_events.reject { |e| e[:optional] }.map { |e| e[:klass] }
      end
    end
  end
end
