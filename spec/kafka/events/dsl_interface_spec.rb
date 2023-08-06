# frozen_string_literal: true

RSpec.describe Kafka::Events::DSLInterface do
  subject(:event_class) { build_event_class(TestEvent, "child.test.event") }

  let(:event) { event_class[foo: 1, bar: ""] }

  describe ".key" do
    it "defines key proc" do
      event_class.key(&:foo)
      expect(event.key).to eq(event.foo.to_s)
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
      expect(event.partition).to eq(event.foo + 2)
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
        expect(event.partition).to eq(event.foo + 2)
      end
    end
  end

  describe ".service" do
    it "defines service class" do
      event_class.service Kafka::Events::Service
      expect(event.service).to eq Kafka::Events::Service
    end
  end

  describe ".produces" do
    it "defines expected produced events" do
      event_class.produces event_class
      expect(event_class.allowed_events)
        .to contain_exactly({ klass: event_class, optional: false })
    end

    context "when produces is defined multiple times" do
      it "defines only first time" do
        event_class.produces event_class
        event_class.produces event_class, optional: true
        expect(event_class.allowed_events)
          .to contain_exactly({ klass: event_class, optional: false })
      end
    end

    context "with optional true" do
      it "defines optional expectation" do
        event_class.produces event_class, optional: true
        expect(event_class.allowed_events)
          .to contain_exactly({ klass: event_class, optional: true })
      end
    end

    context "with wrong class" do
      it "raises error" do
        expect { event_class.produces "Event" }
          .to raise_error(ArgumentError, "\"Event\" is not a Kafka::Events::Base")
      end
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
