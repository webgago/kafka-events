# frozen_string_literal: true

RSpec.describe Kafka::Events::Builder do
  subject(:builder) { described_class.new(event_class) }

  let(:event_class) do
    build_event_class(TestEvent, "child.test.event") do
      key(&:foo)

      headers_schema do
        attribute? :foo, Kafka::Events::Types::String
      end
    end
  end

  let(:payload) { { foo: 1, bar: "" } }
  let(:event) { event_class[payload] }

  shared_examples "correct event" do |topic: "test_topic", key: "1", partition: 1|
    it "ensures event has correct class" do
      expect(event).to be_a(event_class)
    end

    it "ensures event has correct topic" do
      expect(event.to_kafka.topic).to eq(topic)
    end

    it "ensures event has correct key" do
      expect(event.to_kafka.key).to eq(key)
    end

    it "ensures event has correct partition" do
      expect(event.to_kafka.partition).to eq(partition)
    end
  end

  describe "#build" do
    context "with payload" do
      let(:event) { builder.payload(payload).build }

      it_behaves_like "correct event"

      context "when missing keys" do
        let(:payload) { { bar: "" } }

        it "raises error" do
          expect { event }
            .to raise_error(Kafka::Events::SchemaValidationError, '[{:foo=>["foo is missing"]}]')
        end
      end

      context "when extra keys" do
        let(:payload) { { foo: 1, bar: "", baz: false } }

        it "raises error" do
          expect { event }
            .to raise_error(Kafka::Events::SchemaValidationError, '[{:baz=>["baz is not allowed"]}]')
        end
      end
    end

    context "with set method" do
      let(:payload) { { foo: 1, bar: "" } }
      let(:event) { builder.set(set_options).payload(payload).build }

      context "with topic" do
        let(:set_options) { { topic: "some_topic" } }

        it_behaves_like "correct event", topic: "some_topic"
      end

      context "with key" do
        let(:set_options) { { key: "some_key" } }

        it_behaves_like "correct event", key: "some_key"
      end

      context "with partition" do
        let(:set_options) { { partition: 9 } }

        it_behaves_like "correct event", partition: 9
      end
    end

    context "with default headers" do
      subject(:builder) { described_class.new(event_class, headers: { foo: "bar" }) }

      it "merges headers with context headers" do
        event = builder.payload(payload).build
        expect(event.headers.foo).to eq("bar")
      end
    end
  end
end
