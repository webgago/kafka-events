# frozen_string_literal: true

require "forwardable"

module Kafka
  module Events
    class Builder
      extend Forwardable

      # @!method to_h
      # @!method to_kafka
      # @!method call
      def_delegators :build, :to_h, :call, :to_kafka

      # @param [Class<Kafka::Events::Base>] klass
      def initialize(klass)
        @klass = klass
        cleanup
      end

      # @param [Hash] headers
      # @return [Kafka::Events::Builder]
      def headers(headers = {})
        tap { @headers = headers }
      end

      # @param [Hash] attributes
      # @return [Kafka::Events::Builder]
      def payload(attributes = {})
        tap { @payload = attributes }
      end

      def set(topic: nil, key: nil, partition: nil)
        tap do
          @topic = topic.presence
          @key = key.presence
          @partition = partition.presence
        end
      end

      # @param [Hash] attributes
      # @return [Kafka::Events::Base]
      def create(attributes = {})
        payload(attributes).build
      end

      # @return [Kafka::Events::Base]
      def build
        @klass.abstract? && raise(NotImplementedError, "#{self} is an abstract class and cannot be instantiated.")

        @klass.new({ **validate.to_h }.compact)
      ensure
        cleanup
      end

      def data
        {
          topic: @topic || @klass.topic,
          key: @key,
          partition: @partition,
          type: @klass.type,
          payload: @payload,
          headers: @headers
        }.compact
      end

      private

      def validator
        @validator ||= @klass.contract.new
      end

      def validate
        validator.call(data).tap do |validation|
          raise SchemaValidationError, validation unless validation.success?
        end
      end

      def cleanup
        @payload = {}
        @headers = {}
        @topic = nil
        @key = nil
        @partition = nil
      end
    end
  end
end
