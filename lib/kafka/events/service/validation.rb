module Kafka
  module Events
    class Service
      # Class interface for Kafka::Events::Base
      module Validation
        def call
          super
          validate_events!
          events
        end

        def validate_events!
          actual = events.map(&:class)
          missing, unexpected = missing_and_unexpected_events(actual)

          raise(MustProduceEventError.new(self.class, required_events, actual)) if missing.size.positive?
          raise(UnexpectedEventProducedError.new(self.class, expected_events, unexpected)) if unexpected.size.positive?
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
          @optional_events ||= self.class.allowed_events.select { |e| e[:optional] }.map { |e| e[:klass] }
        end

        def required_events
          @required_events ||= self.class.allowed_events.reject { |e| e[:optional] }.map { |e| e[:klass] }
        end
      end
    end
  end
end
