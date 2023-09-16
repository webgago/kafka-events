RSpec.describe Kafka::Events::Context do
  subject(:context) { described_class }

  describe ".with_context" do
    let(:event_ids) { Array.new(6) { SecureRandom.alphanumeric(8) } }

    it "registers event" do
      threads = event_ids.map do |event_id|
        Thread.new do
          context.with_context(event_id: event_id) do
            expect(context.get(:event_id)).to eq(event_id)
          end

          expect(context.get(:event_id)).to be_nil
        end
      end
      threads.each(&:join)
    end
  end

  describe ".get" do
    it "returns nil" do
      expect(context.get(:event_id)).to be_nil

      context.get(:event_id) { |value| expect(value).to be_nil }
    end

    context "when context is set" do
      let(:event_id) { SecureRandom.alphanumeric(8) }

      around do |example|
        context.with_context(event_id: event_id) { example.run }
      end

      it "returns value" do
        expect(context.get(:event_id)).to eq(event_id)
        context.get(:event_id) { |value| expect(value).to eq(event_id) }
      end
    end
  end

  describe ".resolve" do
    context "when context is not set" do
      it "raises KeyError" do
        expect { context.resolve(:context) }.to raise_error(KeyError)
      end

      context "with fallback" do
        it "returns value" do
          expect(context.resolve(:context) { :default }).to eq :default
        end
      end
    end
  end
end
