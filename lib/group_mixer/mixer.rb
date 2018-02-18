require_relative "./group"
require_relative "./weighted_group"

module GroupMixer
  class Mixer
    MAX_AMOUNT = 2 ** ([42].pack('i').size * 16 - 2) - 1

    def initialize(people, past_set, groups, is_separate_reminders)
      @people = people.shuffle
      @groups = groups
      @past_groups = past_set.to_a.map { |s| s.is_a?(WeightedGroup) ? s : WeightedGroup.new(s) }
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

    def make_heuristic_from_past(people, past_set)
      past_set.each_with_object(Hash.new(0)) { |past, pheromone|
        past.members.to_a.combination(2).each do |pair|
          pheromone[Set.new(pair)] += past.weight if (people & pair).size > 1
        end
      }
    end

    def make_link_amount_hash(people, links)
      people.each_with_object(Hash.new) { |person, hash|
        hash[person] = links.select { |pair, value| pair.member? person }
                            .map { |pair, value| value }
                            .inject(0) { |sum, value| sum += value }
      }
    end

    def select_group(groups, person, links)
      relevances = group_relevance(groups, person, links)
      min_relevence = relevances.min{ |x, y| x[1] <=> y[1] }[1]
      min_relevence_groups = relevances.select { |g, v| v == min_relevence }.keys
      max_relevence_group_size = min_relevence_groups.max{ |x, y|
        x.members.size <=> y.members.size
      }.members.size
      min_relevence_groups.select { |g| g.members.size == max_relevence_group_size }.sample
    end

    def group_relevance(groups, person, links)
      groups.each_with_object(Hash.new) { |g, hash|
        hash[g] = g.full? ? MAX_AMOUNT : g.inject(0) { |sum, m| sum += links[Set[m, person]].to_i }
      }
    end
  end
end
