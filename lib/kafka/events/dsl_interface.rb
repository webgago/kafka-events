# frozen_string_literal: true

module Kafka
  module Events
    # Class interface for Kafka::Events::Base
    module DSLInterface
      include Dry::Core::Constants

      def topic(topic = nil)
        return unless schema
        return schema.type.name_key_map[:topic]&.value if topic.nil?

        attribute?(:topic, Types::Strict::String.default(topic))
      end

      def payload_schema(&block)
        define_schema(:payload, &block)
      end

      def headers_schema(&block)
        define_schema :headers, &block
      end

      def rules(&block)
        rules_proc(block) if block_given?
        rules_proc
      end

      def partitioner(object = nil, &block)
        if object.respond_to?(:call) && block_given?
          raise ArgumentError, "partitioner must be either a proc or an object that responds to #call"
        end

        partitioner_proc(block) if block_given?
        partitioner_proc(proc { |*args| object.call(*args) }) if object
        partitioner_proc
      end

      def key(&block)
        key_proc(block) if block_given?
        key_proc
      end

      def define_schema(key, &block)
        if superclass.has_attribute?(key)
          # inherit payload and headers from superclass
          send(:attribute, key, superclass.schema.type.key(key).type, &block)
        else
          send(:attribute, key, &block)
        end
      end
      private :define_schema
    end
  end
end
