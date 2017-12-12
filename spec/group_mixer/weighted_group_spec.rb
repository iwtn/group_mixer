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

  describe '#members' do
    subject {
      described_class.new([1, 2, 2]).members
    }

    it 'returns set uniq members' do
      expect( subject ).to eq Set[1, 2]
    end
  end

  describe '#size' do
    subject {
      described_class.new([], 2).weight
    }

    it 'returns set weight' do
      expect( subject ).to eq 2
    end
  end
end
