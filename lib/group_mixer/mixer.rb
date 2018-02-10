require "group_mixer/group"
require "group_mixer/weighted_group"

module GroupMixer
  class Mixer
    MAX_AMOUNT = 2 ** ([42].pack('i').size * 16 - 2) - 1

    def initialize(people, past_set, group_size, is_separate_reminders)
      @people = people.shuffle
      @past_groups = past_set.to_a.map { |s| s.is_a?(WeightedGroup) ? s : WeightedGroup.new(s) }
      group_size = group_size.to_i
      if group_size.zero?
        raise ZeroGroupSize, 'group_size must be a number greater than 1'
      end
      if is_separate_reminders
        @groups = make_separate_groups(group_size, @people.size)
      else
        @groups = make_groups(group_size, @people.size)
      end
    end

    def execute
      links = make_heuristic_from_past(@people, @past_groups)
      link_amount_hash = make_link_amount_hash(@people, links)

      link_amount_hash.sort { |a, b| b[1]<=>a[1] }.each do |person, amount|
        select_group(@groups, person, links).add person
      end

      @groups.map(&:members)
    end

    private

    def make_groups(group_size, people_size)
      min_member_size, max_group_size = people_size.divmod group_size
      max_group_size.times.map { |n| Group.new(min_member_size + 1) } +
          (group_size - max_group_size).times.map { |n| Group.new(min_member_size) }
    end

    def make_separate_groups(group_size, people_size)
      member_size = people_size / (group_size - 1)
      (group_size - 1).times.map { Group.new(member_size) } +
        [Group.new(people_size % (group_size - 1))]
    end

    def make_heuristic_from_past(people, past_set)
      past_pheromone = Hash.new(0)
      past_set.each do |past|
        past.members.to_a.combination(2).each do |pair|
          if people.include?(pair[0]) && people.include?(pair[1])
            past_pheromone[Set.new(pair)] += past.weight
          end
        end
      end
      past_pheromone
    end

    def make_link_amount_hash(people, links)
      people.each_with_object(Hash.new) do |person, hash|
        hash[person] = links.select { |pair, value| pair.member? person }
                            .map { |pair, value| value }
                            .inject(0) { |sum, value| sum += value }
      end
    end

    def select_group(groups, person, links)
      group_relevance = get_group_relevance(groups, person, links)
      min_relevence = group_relevance.min{ |x, y| x[1] <=> y[1] }[1]
      min_relevence_groups = group_relevance.select { |g, v| v == min_relevence }.keys
      max_relevence_group_size = min_relevence_groups.max{ |x, y|
        x.members.size <=> y.members.size
      }.members.size
      min_relevence_groups.select { |g| g.members.size == max_relevence_group_size }.sample
    end

    def get_group_relevance(groups, person, links)
      groups.each_with_object(Hash.new) { |g, hash|
        if g.full?
          hash[g] = MAX_AMOUNT
        else
          hash[g] = g.inject(0) { |sum, m| sum += links[Set[m, person]].to_i }
        end
      }
    end
  end
end
