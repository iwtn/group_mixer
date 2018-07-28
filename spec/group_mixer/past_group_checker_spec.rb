require "spec_helper"

RSpec.describe GroupMixer::PastGroupChecker do
  let(:groups) { [] }
  let(:past_group_sets) { [] }

  describe '.past_groups' do
    subject { described_class.past_groups(groups, past_group_sets) }

    it { is_expected.to eq({}) }
  end
end
