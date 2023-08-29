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

      # @param [Hash] context
      # @return [Kafka::Events::Builder]
      def context(context = {})
        tap { @context = context }
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

      # @param [Hash] attributes
      # @return [Kafka::Events::Base]
      def create(attributes = {})
        payload(attributes).build
      end

      # @return [Kafka::Events::Base]
      def build
        @klass.abstract? && raise(NotImplementedError, "#{self} is an abstract class and cannot be instantiated.")

        @klass.new({ **validate.to_h, context: context_instance }.compact)
      ensure
        cleanup
      end

      def data
        compile_payload!(context_instance)

        {
          topic: @klass.topic,
          type: @klass.type,
          payload: @payload,
          headers: @headers
        }
      end

      private

      def context_instance
        @context_instance ||= @context.empty? ? nil : @klass::Context.new(@context)
      end

      def validator
        @validator ||= @klass.contract.new
      end

      def compile_payload!(context)
        return @payload if context.nil? || @klass.payload_proc.nil?

        @payload = @klass.payload_proc.call(context, @payload)
      end

      def validate
        validator.call(data, @context).tap do |validation|
          raise SchemaValidationError, validation unless validation.success?
        end
      end

      def cleanup
        @payload = {}
        @headers = {}
        @context = {}
        @context_instance = nil
      end
    end
  end
end
