# frozen_string_literal: true

RSpec.describe Kafka::Events::DSLInterface do
  subject(:event_class) { build_event_class(TestEvent, "child.test.event") }

  let(:event) { event_class[foo: 1, bar: ""] }

  describe ".key" do
    it "defines key proc" do
      event_class.key(&:foo)
      expect(event.to_kafka.key).to eq(event.foo.to_s)
    end
  end

  describe ".type" do
    it "defines type" do
      event_class.type "test.event"
      expect(event.type).to eq("test.event")
    end
  end

  describe ".topic" do
    it "defines topic" do
      event_class.topic "test.topic"
      expect(event.topic).to eq("test.topic")
    end
  end

  describe ".partitioner" do
    it "defines partitioner proc" do
      event_class.partitioner { |event| event.foo + 2 }
      expect(event.to_kafka.partition).to eq(event.foo + 2)
    end

    context "when partitioner is defined both as callable and a block" do
      it "raises error" do
        expect { event_class.partitioner(proc {}) { |event| event.foo + 2 } }
          .to raise_error(ArgumentError)
      end
    end

    context "when partitioner is defined with a callable" do
      it "raises error" do
        event_class.partitioner(proc { |event| event.foo + 2 })
        expect(event.to_kafka.partition).to eq(event.foo + 2)
      end
    end
  end

  describe ".service" do
    it "defines service class" do
      event_class.service Kafka::Events::Service
      expect(event.service).to eq Kafka::Events::Service
    end
  end

  describe "inheritance" do
    subject(:child_event_class) do
      build_event_class(event_class, "child.test.event") do
        payload_schema do
          attribute :zar, Kafka::Events::Types::String
        end
      end
    end

    let(:child_event) { child_event_class[foo: 1, bar: "", zar: "zar"] }

    it "inherits parent attributes" do
      expect(child_event).to be_a(event_class)
      expect(child_event.payload.zar).to eq("zar")
    end
  end
end
