require "group_mixer/version"
require "group_mixer/mixer"

class Set
  def pairs
    Set.new(self.map do |i1|
      self.map do |i2|
        Set[i1, i2] if i1 != i2
      end.compact
    end.flatten)
  end
end

module GroupMixer
  def self.by_group_size(people, past_set, group_size)
    Mixer.new(people, past_set, group_size).execute
  end

  def self.by_member_size(people, past_set, max_member_size)
    group_size = people.size / max_member_size
    Mixer.new(people, past_set, group_size).execute
  end
end
