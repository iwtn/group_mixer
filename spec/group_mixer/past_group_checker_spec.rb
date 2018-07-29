require "spec_helper"

RSpec.describe GroupMixer::PastGroupChecker do
  let(:groups) { [] }
  let(:past_group_sets) { [] }

  describe '.past_groups' do
    subject { described_class.past_groups(groups, past_group_sets) }

    it { is_expected.to eq({}) }

    context 'with past groups' do
      let(:groups) {
        Set.new([
          Set.new([1, 2, 3]),
          Set.new([4, 5, 6]),
          Set.new([7, 8, 9]),
        ])
      }
      let(:past_group_sets) {
        Set.new([
          Set.new([1, 4, 7]),
          Set.new([2, 5, 8]),
          Set.new([3, 6, 9]),
        ])
      }

      it { is_expected.to eq({}) }

      context 'the same group in the past' do
        let(:past_group_sets) {
          Set.new([
            Set.new([1, 2, 9]),
          ])
        }

        it {
          is_expected.to eq({
            1 => [ { member: 2, group: Set.new([1, 2, 9]) } ],
            2 => [ { member: 1, group: Set.new([1, 2, 9]) } ],
          })
        }
      end
    end
  end
end
