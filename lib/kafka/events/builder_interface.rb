# frozen_string_literal: true

module Kafka
  module Events
    # Class interface for Kafka::Events::Base
    module BuilderInterface
      # @return [Kafka::Events::Builder]
      def builder
        @builder ||= ::Kafka::Events::Builder.new(self)
      end

      # @param [Hash] context
      # @return [Kafka::Events::Factory]
      def context(context = {})
        builder.context(context)
      end

      # @param [Hash] headers
      # @return [Kafka::Events::Factory]
      def headers(headers = {})
        builder.headers(headers)
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
      # @param [Hash] context
      # @return [Kafka::Events::Base]
      def create(headers: {}, context: {}, **payload)
        builder.headers(headers).context(context).payload(payload).build
      end

      def [](payload = {})
        builder.payload(payload).build
      end
    end
  end
end
