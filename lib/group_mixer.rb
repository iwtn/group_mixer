require_relative "./group_mixer/mixer"

module GroupMixer
  class ZeroGroupSize < StandardError
  end
  class ZeroMaxMemberSize < StandardError
  end

  def self.by_group_size(people, past_set, group_size, is_separate_reminders = false)
    Mixer.new(people, past_set, group_size, is_separate_reminders).execute
  end

  def self.by_member_size(people, past_set, max_member_size, is_separate_reminders = false)
    if max_member_size.to_f < 1
      raise ZeroMaxMemberSize, 'max_member_size must be a number greater than 1'
    end
    group_size = (people.size / max_member_size.to_f).ceil
    Mixer.new(people, past_set, group_size, is_separate_reminders).execute
  end
end
