# frozen_string_literal: true

RSpec.describe Kafka::Events::Builder do
  subject(:builder) { described_class.new(event_class) }

  let(:event_class) do
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

  describe "#build" do
    context "with payload" do
      it "returns event" do
        expect(builder.payload(payload).build).to be_a(event_class)
      end

      context "when missing keys" do
        let(:payload) { { bar: "" } }

        it "raises error" do
          expect { builder.payload(payload).build }
            .to raise_error(Kafka::Events::SchemaValidationError, '[{:foo=>["foo is missing"]}]')
        end
      end

      context "when extra keys" do
        let(:payload) { { foo: 1, bar: "", baz: false } }

        it "raises error" do
          expect { builder.payload(payload).build }
            .to raise_error(Kafka::Events::SchemaValidationError, '[{:baz=>["baz is not allowed"]}]')
        end
      end
    end

    context "with context" do
      it "returns event" do
        expect(builder.context(instance: 1).payload(bar: "").build).to be_a(event_class)
      end
    end

    context "with topic" do
      let(:payload) { { foo: 1, bar: "" } }
      let(:event) { builder.topic("foo").payload(payload).build }

      it "returns event with new topic" do
        expect(event).to be_a(event_class)
        expect(event.topic).to eq("foo")
      end
    end
  end
end
