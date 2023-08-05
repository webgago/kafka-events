# frozen_string_literal: true

RSpec.describe Kafka::Events::KafkaHeaders do
  subject(:mod) { described_class }

  describe ".to_options" do
    it "returns hash with symbolized keys" do
      expect(mod.to_options({ "X-Kafka-Foo" => "bar" })).to eq(foo: "bar")
    end
  end

  describe ".to_headers" do
    it "returns hash with stringified keys" do
      expect(mod.from_options({ foo: "bar" })).to eq("X-Kafka-Foo" => "bar")
    end
  end
end
