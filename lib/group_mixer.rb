require "group_mixer/version"
require "group_mixer/mixer"
require "group_mixer/weighted_group"

module GroupMixer
  class ZeroGroupSize < StandardError
  end
  class ZeroMaxMemberSize < StandardError
  end

  def self.by_group_size(people, past_set, group_size)
    Mixer.new(people, past_set, group_size).execute
  end

  def self.by_member_size(people, past_set, max_member_size)
    if max_member_size.to_f < 1
      raise ZeroMaxMemberSize, 'max_member_size must be a number greater than 1'
    end
    group_size = (people.size / max_member_size.to_f).ceil
    Mixer.new(people, past_set, group_size).execute
  end
end
