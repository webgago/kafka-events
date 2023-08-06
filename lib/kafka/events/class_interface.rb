# frozen_string_literal: true

module Kafka
  module Events
    # Class interface for Kafka::Events::Base
    module ClassInterface
      include Dry::Core::ClassAttributes

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
        base.defines :topic, :type, :key_proc
        base.defines :partitioner_proc
        base.defines :service
        base.defines :payload_proc
        base.defines :rules_proc
        base.defines :allowed_events
        # bypass partitioner and allow kafka to choose partition
        base.partitioner_proc(proc { -1 })
        base.rules_proc(proc {})
        base.key_proc(proc {})
      end

      attr_reader :abstract
      alias abstract? abstract

      def abstract!
        @abstract = true
      end

      def inherited(klass)
        super
        klass.context
        klass.allowed_events([])
        Job.events << klass unless klass.abstract?
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

      def helper(name, &block)
        define_method(name) do
          if instance_variable_defined?("@#{name}")
            instance_variable_get("@#{name}")
          else
            instance_variable_set("@#{name}", instance_exec(&block))
          end
        end
      end
    end
  end
end
