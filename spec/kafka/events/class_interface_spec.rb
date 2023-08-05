# frozen_string_literal: true

RSpec.describe Kafka::Events::ClassInterface do
  subject(:event_class) { Class.new(TestEvent) }

  let(:event) { event_class[foo: 1, bar: ""] }

  describe ".abstract?" do
    it "returns whether event is abstract" do
      expect(event_class).not_to be_abstract
      event_class.abstract!
      expect(event_class).to be_abstract
    end
  end

  describe "const_missing" do
    it "raises error" do
      expect { event_class::Foo }
        .to raise_error(NameError)
    end

    context "when Context" do
      it "raises error" do
        expect(event_class::Context).to be < Dry::Struct
      end
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
