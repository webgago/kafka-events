RSpec.describe Kafka::Events::Helpers do
  let(:klass) do
    Class.new do
      extend Kafka::Events::Helpers

      helper(:foo) { "bar" }
    end
  end

  describe ".helper" do
    subject { instance.foo }

    let(:instance) { klass.new }

    it { is_expected.to eq "bar" }

    context "when helper is defined" do
      before { instance.foo }

      it { is_expected.to eq "bar" }
    end
  end
end
