# frozen_string_literal: true

RSpec.describe Kafka::Events::Config do
  subject(:config) { Kafka::Events.config }

  it "inherits from Dry::Validation::Config" do
    expect(config).to be_a(Dry::Validation::Config)
  end

  describe "#base_contract_class" do
    it "returns Kafka::Events::Contract" do
      expect(config.base_contract_class).to be(Kafka::Events::Contract)
    end
  end

  describe "#types" do
    it "returns Kafka::Events::Types" do
      expect(config.types).to be(Dry::Types)
    end
  end

  describe "#validate_keys" do
    after do
      config.validate_keys = true
    end

    it "returns true" do
      expect(config.validate_keys).to be(true)
    end

    it "passes config to Contract" do
      expect(Kafka::Events::Contract.config.validate_keys).to be(true)
      config.validate_keys = false
      expect(Kafka::Events::Contract.config.validate_keys).to be(false)
    end
  end
end
