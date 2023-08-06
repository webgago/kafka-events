# frozen_string_literal: true

RSpec.describe Kafka::Events::BuilderInterface do
  subject(:event_class) do
    build_event_class(TestEvent, "child.test.event") do
      context_schema do
        attribute :instance, Kafka::Events::Types::Integer
      end

      payload do |context, payload|
        { **payload, foo: context.instance }
      end
    end
  end

  let(:payload) { { foo: 1, bar: "" } }
  let(:event) { event_class[payload] }

  describe ".builder" do
    it "returns builder" do
      expect(event_class.builder).to be_a(Kafka::Events::Builder)
    end
  end

  describe ".context" do
    it "returns builder" do
      expect(event_class.context(instance: 1)).to be_a(Kafka::Events::Builder)
      expect(event_class.context(instance: 1)).to be event_class.builder
    end
  end

  describe ".headers" do
    it "returns builder" do
      expect(event_class.headers(special: false)).to be_a(Kafka::Events::Builder)
      expect(event_class.headers(special: false)).to be event_class.builder
    end
  end

  describe ".create" do
    let(:payload) { { foo: 1, bar: "" } }
    let(:headers) { { special: false } }

    it "returns event" do
      expect(event_class.create(**payload)).to be_a(event_class)
    end

    context "with headers" do
      it "returns event" do
        expect(event_class.create(**payload, headers: headers)).to be_a(event_class)
      end
    end

    context "with context" do
      subject(:event) do
        event_class.create(**payload, context: { instance: 999 })
      end

      it "returns event" do
        expect(event).to be_a(event_class)
        expect(event.foo).to eq(999)
        expect(event.bar).to eq(payload[:bar])
      end
    end
  end

  describe ".[]" do
    it "returns event" do
      expect(event_class[payload]).to be_a(event_class)
    end
  end
end
