RSpec.describe GroupMixer do
  it "has a version number" do
    expect(GroupMixer::VERSION).not_to be nil
  end

  let(:people) { (0..99).to_a.map(&:to_s) }
  let(:past_set) {
    people[0..(people.size/2 - 1)].each_slice(10).to_a
  }

  describe '.by_group_size' do
    let(:group_size) { 12 }
    let(:is_separate_reminders) { false }
    subject {
      GroupMixer.by_group_size(people, past_set, group_size, is_separate_reminders)
    }

    it "return groups of the specified size" do
      expect(subject.size).to eq 12
    end

    context 'there are a new member' do
      let(:people) { (0..100).to_a.map(&:to_s) }

      it "return all members" do
        expect(subject.map(&:to_a).flatten.uniq.size).to eq 101
      end
    end

    context 'there is the best answer' do
      let(:past_set) {
        [
          %w(0 3 6),
          %w(1 4 7),
          %w(2 5 8),

          %w(0 4 8),
          %w(1 5 6),
          %w(2 3 7),

          %w(0 5 7),
          %w(1 3 8),
          %w(2 4 6),
        ]
      }
      let(:people) { past_set.flatten.uniq }
      let(:group_size) { 3 }

      it 'return the best answer' do
        expect(Set.new(subject)).to eq Set[
          Set.new(%w(0 1 2)),
          Set.new(%w(3 4 5)),
          Set.new(%w(6 7 8)),
        ]
      end
    end

    context 'past_set is nil' do
      let(:past_set) { nil }

      it 'is not raise Exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'group_size is 0' do
      let(:group_size) { 0 }

      it 'is raise Exception' do
        expect { subject }.to raise_error(GroupMixer::ZeroGroupSize)
      end
    end

    context 'is_separate_reminders is true' do
      let(:is_separate_reminders) { true }

      it do
        expect(subject.map(&:size).min).to eq 1
      end
    end
  end

  describe '.by_member_size' do
    let(:member_size) { 9 }
    let(:is_separate_reminders) { false }
    subject {
      GroupMixer.by_member_size(people, past_set, member_size, is_separate_reminders)
    }

    it "return group of specified member size" do
      expect(subject.first.size).to eq 9
    end

    context 'devisible by member size' do
      let(:member_size) { 10 }

      it "returns divided result" do
        expect(subject.size).to eq 10
      end
    end

    context 'member_size is 0' do
      let(:member_size) { 0 }

      it 'is raise Exception' do
        expect { subject }.to raise_error(GroupMixer::ZeroMaxMemberSize)
      end
    end

    context 'is_separate_reminders is true' do
      let(:is_separate_reminders) { true }

      it do
        expect(subject.map(&:size).min).to eq 1
      end
    end
  end

  describe '.make_groups_by_group_size' do
    subject {
      GroupMixer.__send__(:make_groups_by_group_size, people_size, group_size, is_separate_reminders)
    }

    context 'divide 13 people into 4 groups' do
      let(:people_size) { 13 }
      let(:group_size) { 4 }

      context 'separate on average' do
        let(:is_separate_reminders) { false }
        it { is_expected.to eq [4, 3, 3, 3] }
      end

      context 'sort out remainders' do
        let(:is_separate_reminders) { true }
        it { is_expected.to eq [4, 4, 4, 1] }
      end
    end

    context 'divide 10 people into 4 groups' do
      let(:people_size) { 10 }
      let(:group_size) { 4 }

      context 'separate on average' do
        let(:is_separate_reminders) { false }
        it { is_expected.to eq [3, 3, 2, 2] }
      end

      context 'sort out remainders' do
        let(:is_separate_reminders) { true }
        it { is_expected.to eq [3, 3, 3, 1] }
      end
    end
  end

  describe '.make_groups_by_member_size' do
    subject {
      GroupMixer.__send__(:make_groups_by_member_size, people_size, member_size, is_separate_reminders)
    }

    context 'separate 13 people into groups of 4 people' do
      let(:people_size) { 13 }
      let(:member_size) { 4 }

      context 'separate on average' do
        let(:is_separate_reminders) { false }
        it { is_expected.to eq [4, 3, 3, 3] }
      end

      context 'sort out remainders' do
        let(:is_separate_reminders) { true }
        it { is_expected.to eq [4, 4, 4, 1] }
      end
    end

    context 'separate 9 people into groups of 4 people' do
      let(:people_size) { 9 }
      let(:member_size) { 4 }

      context 'separate on average' do
        let(:is_separate_reminders) { false }
        it { is_expected.to eq [3, 3, 3] }
      end

      context 'sort out remainders' do
        let(:is_separate_reminders) { true }
        it { is_expected.to eq [4, 4, 1] }
      end
    end
  end
end
