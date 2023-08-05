# frozen_string_literal: true

module Kafka
  module Events
    class Error < StandardError; end

    # This error is raised when an event is created with invalid attributes.
    class SchemaValidationError < Error
      # @return [Dry::Validation::Result]
      attr_reader :validation

      # @param [Dry::Validation::Result] validation
      def initialize(validation)
        @validation = validation
        super(validation.errors(full: true).to_h.values.flatten)
      end
    end

    class ProduceEventError < Error
      attr_reader :klass, :expected, :actual

      def initialize(klass, expected, actual)
        @klass = klass
        @expected = expected
        @actual = actual
        actual = ["nothing"] if actual.empty?
        expected = ["nothing"] if expected.empty?

        super("\n\texpected: #{klass} => #{expected.join(", ")}\n\tproduced: #{klass} => #{actual.join(", ")}")
      end
    end

    class MustProduceEventError < ProduceEventError
    end

    class UnexpectedEventProducedError < ProduceEventError
    end
  end
end
