# frozen_string_literal: true

module Kafka
  module Events
    module Types
      include Dry.Types()

      # rubocop:disable Naming/MethodName

      EventType = Types::String.constrained(format: /\A([a-zA-Z._])+\z/)
      EventTopic = Types::String.constrained(format: /\A([a-zA-Z._])+\z/)

      def self.Subclass(klass)
        Types::Class.constrained(case: ->(rel) { klass >= rel })
      end

      # rubocop:enable Naming/MethodName
    end
  end
end
