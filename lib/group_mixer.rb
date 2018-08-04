require_relative "./group_mixer/mixer"

module GroupMixer
  class ZeroGroupSize < StandardError
  end
  class ZeroMaxMemberSize < StandardError
  end

  def self.by_group_size(people, past_set, group_size, is_separate_reminders = false)
    if group_size.zero?
      raise ZeroGroupSize, 'group_size must be a number greater than 1'
    end
    max_member_size = (people.size.to_f / group_size).ceil
    rest = people.size % max_member_size
    groups = make_groups(rest, group_size, max_member_size, is_separate_reminders)
    Mixer.new(people, past_set, groups, is_separate_reminders).execute
  end

  def self.by_member_size(people, past_set, max_member_size, is_separate_reminders = false)
    if max_member_size.to_f < 1
      raise ZeroMaxMemberSize, 'max_member_size must be a number greater than 1'
    end
    rest = people.size % max_member_size
    group_size = (people.size.to_f / max_member_size).ceil
    groups = make_groups(rest, group_size, max_member_size, is_separate_reminders)
    Mixer.new(people, past_set, groups, is_separate_reminders).execute
  end

  private

  def self.make_groups_hoge(group_size_set)
    group_size_set.map { |s| Group.new(s) }
  end

  def self.make_groups_by_group_size(people_size, group_size, is_separate_reminders)
    max_mem = (people_size.to_f / group_size).ceil
    if is_separate_reminders
      rest = people_size % max_mem
      if rest.zero?
        Array.new(group_size) { max_mem }
      else
        Array.new(group_size - 1) { max_mem } + [rest]
      end
    else
      rest = people_size % group_size
      if rest.zero?
        Array.new(group_size) { max_mem }
      else
        Array.new(rest) { max_mem } + Array.new(group_size - rest) { max_mem - 1 }
      end
    end
  end

  def self.make_groups_by_member_size(people_size, member_size, is_separate_reminders)
    group_size = (people_size.to_f / member_size).ceil
    if is_separate_reminders
      rest = people_size % member_size
      return Array.new(group_size) { member_size } if rest.zero?

      Array.new(group_size - 1) { member_size } + [rest]
    else
      rest = people_size % group_size
      if rest.zero?
        msize = (people_size < group_size * member_size) ? member_size - 1 : member_size
        Array.new(group_size) { msize }
      else
        Array.new(rest) { member_size } + Array.new(group_size - rest) { member_size - 1 }
      end
    end
  end

  def self.make_groups(rest, group_size, max_member_size, is_separate_reminders)
    return  Array.new(group_size) { Group.new(max_member_size) } if rest.zero?

    if is_separate_reminders
      Array.new(group_size - 1) { Group.new(max_member_size) } + [Group.new(rest)]
    else
      min_group_size = max_member_size - rest
      if group_size - min_group_size < 1
        return Array.new(1) { Group.new(rest) }
      end
      Array.new(group_size - min_group_size) { Group.new(max_member_size) } +
        Array.new(min_group_size) { Group.new(max_member_size - 1) }
    end
  end
end
