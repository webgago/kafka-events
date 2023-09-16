RSpec.describe Kafka::Events::Context do
  subject(:context) { described_class }

  describe ".with_context" do
    let(:event_ids) { Array.new(6) { SecureRandom.alphanumeric(8) } }

    it "registers event" do
      threads = event_ids.map do |event_id|
        Thread.new do
          context.with_context(event_id: event_id) do
            expect(context.resolve(:event_id)).to eq(event_id)
          end

          expect(context.resolve(:event_id)).to be_nil
        end
      end
      threads.each(&:join)
    end
  end
end
