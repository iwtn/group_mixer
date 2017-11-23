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
    subject {
      GroupMixer.by_group_size(people, past_set, group_size)
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
  end

  describe '.by_member_size' do
    let(:member_size) { 9 }
    subject {
      GroupMixer.by_member_size(people, past_set, member_size)
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
  end
end
