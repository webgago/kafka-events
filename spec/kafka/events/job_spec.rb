# frozen_string_literal: true

RSpec.describe Kafka::Events::Job do
  subject(:job) { described_class.new(klass: event_class, params: params) }

  let(:service_class) do
    returning = actual
    expected = self.expected
    optional = self.optional

    Class.new(Kafka::Events::Service) do
      expected.each { |e| produces(e) }
      optional.each { |e| produces(e, optional: true) }

      define_method :call do
        [returning].flatten.each { |e| produce(e) }
      end
    end
  end

  let(:event_class) do
    service_class = self.service_class
    build_event_class(TestEvent, "child.test.event") do
      service service_class
    end
  end

  let(:params) { { foo: 1, bar: "" } }

  describe "#perform" do
    subject(:perform) { job.perform }

    let(:optional) { [] }
    let(:expected) { [] }

    context "when producer specified" do
      subject(:job) { described_class.new(klass: event_class, params: params, producer: producer) }

      let(:producer) { double(:produce) }
      let(:expected) { [TestEvent] }
      let(:actual) { [TestEvent.create(foo: 1, bar: "")] }

      before do
        allow(producer).to receive(:call)
      end

      it "calls producer" do
        perform
        expect(producer).to have_received(:call)
      end
    end

    context "when producer is not specified" do
      let(:producer) { double(:produce, nil?: true, call: true) }
      let(:expected) { [TestEvent] }
      let(:actual) { [TestEvent.create(foo: 1, bar: "")] }

      it "calls producer" do
        perform
        expect(producer).not_to have_received(:call)
      end
    end

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
  end
end
