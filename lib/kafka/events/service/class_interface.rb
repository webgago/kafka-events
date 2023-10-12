# frozen_string_literal: true

module Kafka
  module Events
    class Service
      # Class interface for Kafka::Events::Base
      module ClassInterface
        include Dry::Core::ClassAttributes

        def self.extended(base)
          base.class_attribute :allowed_events, default: [].freeze
        end

        def produces(*klasses, optional: false)
          current = allowed_events.map { |e| e[:klass] }
          klasses.each do |klass|
            next if current.include?(klass)

            _ensure_argument(klass)
            self.allowed_events += [{ klass: klass, optional: optional }]
          end
        end

        def call(*args, **kwargs)
          instance = new(*args, **kwargs)
          instance.tap(&:call)
        end

        private def _ensure_argument(klass)
          return unless !klass.is_a?(Class) || !(klass < Kafka::Events::Base)

          raise ArgumentError, "#{klass.inspect} is not a Kafka::Events::Base"
        end
      end
    end
  end
end
