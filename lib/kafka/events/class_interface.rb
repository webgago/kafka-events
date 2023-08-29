# frozen_string_literal: true

module Kafka
  module Events
    # Class interface for Kafka::Events::Base
    module ClassInterface
      include Dry::Core::ClassAttributes
      include Kafka::Events::Helpers

      # @!method topic
      #  @return [String]
      #
      # @!method type
      #  @return [String]
      #
      # @!method key
      #  @return [String, nil]
      #
      # @!method service
      #  @return [Proc]
      #
      # @param [Class<Kafka::Events::Base>] base
      def self.extended(base)
        super
        base.defines :topic, :key_proc
        base.defines :partitioner_proc
        base.defines :service
        base.defines :payload_proc
        base.defines :rules_proc
        # bypass partitioner and allow kafka to choose partition
        base.partitioner_proc(proc { -1 })
        base.rules_proc(proc {})
        base.key_proc(proc {})
      end

      attr_reader :abstract, :allowed_events
      alias abstract? abstract

      def type(type = nil)
        return @type if type.nil?

        Job.defined_events[type] = self
        @type = type
      end

      def abstract!
        @abstract = true
      end

      def inherited(klass)
        super
        klass.context
        klass.instance_variable_set(:@allowed_events, [])
      end

      def const_missing(sym)
        case sym
        when :Context
          const_set :Context, Class.new(Dry::Struct)
        else
          super
        end
      end

      def contract
        @contract ||= ContractBuilder.build(schema, &rules)
      end
    end
  end
end
