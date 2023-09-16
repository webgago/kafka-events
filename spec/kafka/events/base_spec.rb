# frozen_string_literal: true

RSpec.describe Kafka::Events::Base do
  subject(:event_class) { build_event_class(TestEvent, "child.test.event") }

  let(:payload) { { foo: 1, bar: "" } }
  let(:headers) { { special: true } }
  let(:event) { event_class.create(**payload) }

  shared_examples "creates new event" do
    it { is_expected.to be_a(event_class) }
    it { expect(create.payload.foo).to eq(payload[:foo]) }
    it { expect(create.payload.bar).to eq(payload[:bar]) }
  end

  shared_examples "has default headers" do
    it { expect(create.headers.special).to be_falsey }
  end

  shared_examples "has custom headers" do
    it { expect(create.headers.special).to be_truthy }
  end

  describe ".create" do
    subject(:create) { event_class.create(**attributes) }

    context "when no arguments given" do
      let(:attributes) { {} }

      it "raises SchemaValidationError" do
        expect { create }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end

    context "when payload given" do
      let(:attributes) { payload }

      include_examples "creates new event"
      include_examples "has default headers"
    end

    context "when payload inlined and headers given" do
      let(:attributes) { { **payload, headers: headers } }

      include_examples "creates new event"
      include_examples "has custom headers"
    end

    context "when type not defined" do
      around do |ex|
        type = event_class.type
        event_class.type("")
        ex.run
        event_class.type(type)
      end

      it "raises SchemaValidationError" do
        expect { event_class.create(**payload) }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end

    context "when type is not valid" do
      around do |ex|
        type = event_class.type
        event_class.type("123")
        ex.run
        event_class.type(type)
      end

      it "raises SchemaValidationError" do
        expect { event_class.create(**payload) }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end

    context "when topic not defined" do
      around do |ex|
        topic = event_class.topic
        event_class.topic("")
        ex.run
        event_class.topic(topic)
      end

      it "raises SchemaValidationError" do
        expect { event_class.create(**payload) }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end

    context "when topic is not valid" do
      around do |ex|
        topic = event_class.topic
        event_class.topic("$topic")
        ex.run
        event_class.topic(topic)
      end

      it "raises SchemaValidationError" do
        expect { event_class.create(**payload) }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end
  end

  describe ".[]" do
    subject(:create) { event_class[payload] }

    include_examples "creates new event"
    include_examples "has default headers"
  end

  describe ".to_kafka" do
    subject(:to_kafka) { event_class.create(**attributes).to_kafka }

    let(:attributes) { { **payload, headers: headers } }
    let(:expected_payload) { payload.merge(type: event_class.type) }
    let(:expected_headers) { { "X-Kafka-Special" => "true" } }

    it { is_expected.to be_a(Kafka::Events::KafkaMessage) }
    it { expect(to_kafka.value).to eq(expected_payload) }
    it { expect(to_kafka.headers).to eq(expected_headers) }
    it { expect(to_kafka.topic).to eq(event_class.topic) }
    it { expect(to_kafka.partition).to eq(1) }
    it { expect(to_kafka.key).to be_nil }
  end

  describe ".partitioner" do
    subject(:partition) { event.to_kafka.partition }

    context "with default partitioner" do
      it { is_expected.to eq(1) }
    end

    context "with custom partitioner" do
      let(:payload) { { foo: 9, bar: "" } }
      let(:partitioner_proc) { proc { |event| event.payload.foo % 2 } }

      before do
        event_class.partitioner_proc(partitioner_proc)
      end

      after do
        event_class.partitioner_proc(proc { 1 })
      end

      it { is_expected.to eq(partitioner_proc.call(event)) }
    end
  end

  context "when abstract" do
    describe ".abstract?" do
      subject(:event_class) do
        Class.new(TestEvent) do
          abstract!
        end
      end

      it { is_expected.to be_abstract }
      it { expect { event_class[payload] }.to raise_error(NotImplementedError) }
      it { expect { event_class.create(**payload) }.to raise_error(NotImplementedError) }
    end
  end

  describe ".type" do
    it { expect(event_class.type).to eq("child.test.event") }

    context "when type is not set" do
      before { event_class.type("") }

      it "raises SchemaValidationError" do
        expect { event_class.create(**payload) }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end
  end

  describe ".topic" do
    it { expect(event_class.topic).to eq("test_topic") }

    context "when topic is not set" do
      before { event_class.topic("") }

      it "raises SchemaValidationError" do
        expect { event_class.create(**payload) }
          .to raise_error(Kafka::Events::SchemaValidationError)
      end
    end
  end
end
