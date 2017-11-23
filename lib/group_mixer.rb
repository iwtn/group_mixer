require "group_mixer/version"
require "group_mixer/mixer"

module GroupMixer
  def self.by_group_size(people, past_set, group_size)
    Mixer.new(people, past_set, group_size).execute
  end

  def self.by_member_size(people, past_set, max_member_size)
    group_size = (people.size / max_member_size.to_f).ceil
    Mixer.new(people, past_set, group_size).execute
  end
end
