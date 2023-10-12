# frozen_string_literal: true

RSpec.describe Kafka::Events::ClassInterface do
  subject(:event_class) { build_event_class(TestEvent, "child.test.event") }

  let(:event) { event_class[foo: 1, bar: ""] }

  describe ".abstract?" do
    it "returns whether event is abstract" do
      expect(event_class).not_to be_abstract
      event_class.abstract!
      expect(event_class).to be_abstract
    end
  end

  describe ".contract" do
    it "returns an instance of Contract" do
      expect(event_class.contract).to be < Kafka::Events::Contract
    end
  end

  describe ".helper" do
    it "defines helper method" do
      event_class.helper(:method1) { "bar" }
      expect(event.method1).to eq("bar")
    end
  end
end
