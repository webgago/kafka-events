# frozen_string_literal: true

RSpec.describe Kafka::Events::ContractBuilder do
  subject(:builder) { described_class }

  let(:event_class) do
    Class.new(Kafka::Events::Base) do
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
  end

  it "returns an instance of Contract" do
    expect(builder.build(event_class.schema)).to be < Kafka::Events::Contract
  end

  context "when event class is missing configuration" do
    let(:event_class) do
      Class.new(Kafka::Events::Base)
    end

    it "does not raise error" do
      expect { builder.build(event_class.schema) }.not_to raise_error
    end

    it "returns an instance of Contract" do
      expect(builder.build(event_class.schema)).to be < Kafka::Events::Contract
    end
  end
end
