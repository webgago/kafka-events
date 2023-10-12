# frozen_string_literal: true

RSpec.describe Kafka::Events::Service::ClassInterface do
  subject(:service_class) do
    Class.new(Kafka::Events::Service) do
      produces TestEvent
    end
  end

  describe ".allowed_events" do
    subject { service_class.allowed_events }

    it { is_expected.to eq [{ klass: TestEvent, optional: false }] }

    context "when inherits" do
      subject { service_class.allowed_events }

      let(:service_class) do
        Class.new(parent_service_class)
      end

      let(:parent_service_class) do
        Class.new(Kafka::Events::Service) do
          produces TestEvent
        end
      end

      it { is_expected.to eq [{ klass: TestEvent, optional: false }] }
    end

    context "when produces optional event" do
      subject { service_class.allowed_events }

      let(:service_class) do
        Class.new(Kafka::Events::Service) do
          produces TestEvent, optional: true
        end
      end

      it { is_expected.to eq [{ klass: TestEvent, optional: true }] }
    end

    context "when produces wrong class" do
      let(:service_class) do
        Class.new(Kafka::Events::Service)
      end

      it { expect { service_class.produces(Class.new) }.to raise_error(ArgumentError) }
    end

    context "when produces multiple times" do
      let(:service_class) do
        Class.new(Kafka::Events::Service)
      end

      it "adds once" do
        service_class.produces(TestEvent)
        service_class.produces(TestEvent)
        expect(service_class.allowed_events).to contain_exactly({ klass: TestEvent, optional: false })
      end
    end
  end
end
