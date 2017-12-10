require "spec_helper"

RSpec.describe GroupMixer::WeightedGroup do
  subject {
    described_class.new
  }

  describe '#initialize' do
    it 'can initialize' do
      expect( subject.class ).to eq described_class
    end
  end
end
