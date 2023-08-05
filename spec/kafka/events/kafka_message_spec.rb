# frozen_string_literal: true

RSpec.describe Kafka::Events::KafkaMessage do
  subject(:message) do
    described_class.new(
      value: { foo: 1, bar: "" },
      headers: { special: true },
      topic: "test_topic",
      key: "test_key",
      partition: 1
    )
  end

  describe "#to_waterdrop" do
    it "returns hash with waterdrop message" do
      expect(message.to_waterdrop).to eq(
        payload: { foo: 1, bar: "" }.to_json,
        key: "test_key",
        topic: "test_topic",
        headers: { "X-Kafka-Special" => "true" },
        partition: 1
      )
    end
  end
end
