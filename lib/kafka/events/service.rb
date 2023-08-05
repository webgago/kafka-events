# frozen_string_literal: true

module Kafka
  module Events
    class Service
      extend Dry::Initializer

      param :event, Types.Instance(Kafka::Events::Base)
      option :events, Types::Array.of(Types.Instance(Kafka::Events::Base)), default: -> { [] }

      def self.new(*args, **kwargs)
        # Make IDEs think *args are fine for initialize
        super
      end

      def call; end

      protected

      def produce(event)
        events << event if event.is_a?(Kafka::Events::Base)
      end
    end
  end
end
