require "group_mixer/version"
require "group_mixer/group"

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
  MAX_AMOUNT = 2 ** ([42].pack('i').size * 16 - 2) - 1

  def self.by_group_size(people, past_set, group_size)
    new(people, past_set, group_size).execute
  end

  def self.by_member_size(people, past_set, max_member_size)
    group_size = people.size / max_member_size
    new(people, past_set, group_size).execute
  end

  def execute
    links = make_heuristic_from_past(@past_set)
    link_amount_hash = make_link_amount_hash(@people, links)

    link_amount_hash.sort {|a, b| b[1]<=>a[1]}.map{|k, v| k }.each do |person|
      select_group(@groups, person, links).add person
    end

    @groups.map(&:members)
  end

  private

  def initialize(people, past_set, group_size)
    @people = people
    @past_set = past_set
    min_member_size, max_group_size = people.size.divmod group_size
    @groups = make_groups(group_size, max_group_size, min_member_size)
  end

  def make_groups(group_size, max_group_size, min_member_size)
    max_group_size.times.map { |n| Group.new(min_member_size + 1) } +
        (group_size - max_group_size).times.map { |n| Group.new(min_member_size) }
  end

  def make_heuristic_from_past(past_set)
    past_pheromone = Hash.new(0)
    past_set.each do |past|
      Set.new(past).pairs.each do |pair|
        past_pheromone[pair] += 1
      end
    end
    past_pheromone
  end

  def make_link_amount_hash(people, links)
    hash = {}
    people.each do |person|
      amount = 0
      links.each do |pair, value|
        amount += value if pair.member? person
      end
      hash[person] = amount
    end
    hash
  end

  def select_group(groups, person, links)
    group_amounts = {}
    groups.each do |g|
      if g.full?
        group_amounts[g] = MAX_AMOUNT
      else
        amount = 0
        g.each do |member|
          amount += links[Set[member, person]].to_i
        end
        group_amounts[g] = amount
      end
    end
    group_amounts.min{ |x, y| x[1] <=> y[1] }[0]
  end
end
