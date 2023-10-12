# frozen_string_literal: true

module Kafka
  module Events
    # Class interface for Kafka::Events::Base
    module BuilderInterface
      # @return [Kafka::Events::Builder]
      def builder(headers: {}, payload: {})
        ::Kafka::Events::Builder.new(self, headers: headers, payload: payload)
      end

      # @param [Hash] headers
      # @return [Kafka::Events::Builder]
      def headers(headers = {})
        builder.headers(headers)
      end

      def set(topic: nil, key: nil, partition: nil)
        builder.set(topic: topic, key: key, partition: partition)
      end

      # Allows to omit payload and headers and wrap attributes automatically
      #
      # @example
      #  ApplicationEvent.create(foo: "bar")
      #   # => #<ApplicationEvent payload={foo: "bar"} headers={}>
      #
      #  ApplicationEvent.create(payload: {foo: "bar"})
      #   # => #<ApplicationEvent payload={foo: "bar"} headers={}>
      #
      #  ApplicationEvent.create(payload: {foo: "bar"}, headers: { some: "header" })
      #   # => #<ApplicationEvent payload={foo: "bar"} headers={ some: "header" }>
      #
      #  ApplicationEvent.create({foo: "bar"}, headers: { some: "header" })
      #   # => #<ApplicationEvent payload={foo: "bar"} headers={ some: "header" }>
      #
      #  ApplicationEvent[foo: "bar", headers: { some: "header" })]
      #
      # @api public
      # @param payload [Hash] event attributes
      # @param [Hash] headers
      # @return [Kafka::Events::Base]
      def create(headers: {}, **payload)
        builder.headers(headers).create(payload)
      end

      def [](payload = {})
        builder.create(payload)
      end
    end
  end
end
