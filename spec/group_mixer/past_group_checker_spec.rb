require "spec_helper"

RSpec.describe GroupMixer::PastGroupChecker do
  subject {
      described_class.new
  }

  describe '#initialize' do
    it 'can initialize' do
      expect( subject.class ).to eq described_class
    end
  end
end
