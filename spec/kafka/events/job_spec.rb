# frozen_string_literal: true

RSpec.describe Kafka::Events::Job do
  subject(:job) { described_class.new(klass: event_class, params: params) }

  let(:service_class) do
    returning = actual

    Class.new(Kafka::Events::Service) do
      define_method :call do
        [returning].flatten.each { |e| produce(e) }
      end
    end
  end

  let(:event_class) do
    expected = self.expected
    optional = self.optional
    service_class = self.service_class
    build_event_class(TestEvent, "child.test.event") do
      expected.each { |e| produces(e) }
      optional.each { |e| produces(e, optional: true) }
      service service_class
    end
  end

  let(:params) { { foo: 1, bar: "" } }

  describe "#perform" do
    subject(:perform) { job.perform }

    let(:optional) { [] }
    let(:expected) { [] }

    context "when expecting produced events" do
      let(:expected) { [TestEvent] }

      context "when returning nil" do
        let(:actual) { nil }

        it "validates the produced events" do
          expect { perform }.to raise_error(Kafka::Events::MustProduceEventError)
        end
      end

      context "when returning wrong type" do
        let(:actual) { [build_event_class(TestEvent, "wrong.test.event").create(foo: 1, bar: "")] }

        it "validates the produced events" do
          expect { perform }.to raise_error(Kafka::Events::MustProduceEventError)
        end
      end

      context "when returning unexpected type" do
        let(:actual) do
          [
            TestEvent.create(foo: 1, bar: ""),
            build_event_class(TestEvent, "wrong.test.event").create(foo: 1, bar: "")
          ]
        end

        it "validates the produced events" do
          expect { perform }.to raise_error(Kafka::Events::UnexpectedEventProducedError)
        end
      end

      context "when returning correct type" do
        let(:actual) { [TestEvent.create(foo: 1, bar: "")] * 2 }

        it "validates the produced events" do
          expect { perform }.not_to raise_error
        end

        it "returns the produced events" do
          expect(perform).to all(be_a(Kafka::Events::KafkaMessage))
        end
      end
    end

    context "when not expecting produced events" do
      let(:expected) { [] }

      context "when returning nil" do
        let(:actual) { [] }

        it "validates the produced events" do
          expect { perform }.not_to raise_error
        end

        it "returns empty array" do
          expect(perform).to eq([])
        end
      end

      context "when returning wrong type" do
        let(:actual) { build_event_class(TestEvent, "wrong.test.event").create(foo: 1, bar: "") }

        it "validates the produced events" do
          expect { perform }.to raise_error(Kafka::Events::UnexpectedEventProducedError)
        end
      end
    end

    context "when optional events are produced" do
      let(:optional) { [TestEvent] }

      context "when returning nil" do
        let(:actual) { nil }

        it "validates the produced events" do
          expect { perform }.not_to raise_error
        end

        it "returns empty array" do
          expect(perform).to eq([])
        end
      end

      context "when returning wrong type" do
        let(:actual) { [build_event_class(TestEvent, "wrong.test.event").create(foo: 1, bar: "")] }

        it "validates the produced events" do
          expect { perform }.to raise_error(Kafka::Events::UnexpectedEventProducedError)
        end
      end

      context "when returning correct type" do
        let(:actual) { [TestEvent.create(foo: 1, bar: "")] * 2 }

        it "validates the produced events" do
          expect { perform }.not_to raise_error
        end

        it "returns the produced events" do
          expect(perform).to all(be_a(Kafka::Events::KafkaMessage))
        end
      end
    end

    context "when parent event defines required event" do
      before do
        TestEvent.produces(TestEvent)
      end

      let(:actual) { [TestEvent.create(foo: 1, bar: "")] }

      it "overrides in child" do
        expect(event_class.allowed_events).to be_empty
      end
    end
  end
end
