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
  end

  describe '.by_member_size' do
    let(:member_size) { 9 }
    subject {
      GroupMixer.by_member_size(people, past_set, member_size)
    }

    it "return group of specified member size" do
      expect(subject.first.size).to eq 9
    end
  end
end
