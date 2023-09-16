# frozen_string_literal: true

class TestEvent < Kafka::Events::Base
  topic "test_topic"
  type "test.event"

  payload_schema do
    attribute :foo, Kafka::Events::Types::Integer
    attribute :bar, Kafka::Events::Types::String
  end

  headers_schema do
    attribute :special, Kafka::Events::Types::Bool.default(false)
  end

  partitioner { 1 }
end

module EventClassFactory
  def build_event_class(parent, type, &block)
    Class.new(parent) do
      type(type)
      instance_exec(&block) if block
    end
  end
end

RSpec.configure do |config|
  config.include EventClassFactory
end
