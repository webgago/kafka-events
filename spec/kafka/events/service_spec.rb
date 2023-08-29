# frozen_string_literal: true

RSpec.describe Kafka::Events::Service do
  subject(:service) { described_class.new(event) }

  let(:event) { TestEvent[foo: 1, bar: "baz"] }

  describe "#call" do
    it "does nothing" do
      expect { service.call }.not_to raise_error
    end
  end

  describe "#events" do
    before { service.call }

    let(:klass) do
      Class.new(Kafka::Events::Service) do
        def call
          produce(TestEvent[foo: 2, bar: "baz"])
          produce(TestEvent, foo: 3, bar: "baz", headers: { special: true })
        end
      end
    end
    let(:service) { klass.new(event) }

    it "returns produced events" do
      expect(service.events).to have_attributes(length: 2)
      expect(service.events).to all(be_a(TestEvent))
    end
  end
end
