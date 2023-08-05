# frozen_string_literal: true

module Kafka
  module Events
    module KafkaHeaders
      KAFKA_PREFIX = "X-Kafka-"
      OPTION_PREFIX = ""

      module_function

      Type = Types::Hash.default({}.freeze).constructor do |value|
        from_options(value).except(*%i[x_topic x_partition x_offset])
      end

      # Convert keys of a given Hash
      # from "X-Kafka-Header-Name"
      # to :x_header_name
      #
      # @example
      #   headers = { "X-Kafka-Limit" => 100, "X-Kafka-Initiator" => "Foo" }
      #   KafkaHeaders.to_options(headers)
      #   # => { x_limit: 100, x_initiator: "Foo" }
      #
      # @param [Hash<String, Object>] headers
      # @return [Hash<Symbol, Object>]
      def to_options(headers, kafka_prefix: KAFKA_PREFIX, option_prefix: OPTION_PREFIX)
        headers.select { |k, _| k.include?(kafka_prefix) }
               .transform_keys { |k| k.sub(kafka_prefix, option_prefix).underscore.to_sym }
      end

      # Convert keys of a given Hash
      # from :x_header_name
      # to "X-Kafka-Header-Name"
      #
      # @example
      #   options = { x_limit: 100, x_initiator: "Foo" }
      #   KafkaHeaders.from_options(options)
      #   # => { "X-Kafka-Limit" => 100, "X-Kafka-Initiator" => "Foo" }
      #
      # @param [Hash<Symbol, Object>] options
      # @return [Hash<String, Object>]
      def from_options(options, kafka_prefix: KAFKA_PREFIX, option_prefix: OPTION_PREFIX)
        headers = options.compact.transform_keys do |k|
          header = k.to_s.sub(option_prefix, "").titleize.tr(" ", "-").sub(kafka_prefix, "")
          "#{kafka_prefix}#{header}"
        end
        headers.transform_values(&:to_s)
      end
    end
  end
end
