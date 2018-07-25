module GroupMixer
  class PastGroupChecker
    def self.past_groups(groups, past_group_sets)
      past_same_groups = {}
      groups.each do |g|
        g.to_a.combination(2) do |m1, m2|
          past_group_sets.each do |pg|
            if pg.include?(m1) && pg.include?(m2)
              if past_same_groups[m1].nil?
                past_same_groups[m1] = [{ group: pg, member: m2 }]
              else
                past_same_groups[m1] << { group: pg, member: m2 }
              end
              if past_same_groups[m2].nil?
                past_same_groups[m2] = [{ group: pg, member: m1 }]
              else
                past_same_groups[m2] << { group: pg, member: m1 }
              end
            end
          end
        end
      end
      return past_same_groups
    end
  end
end
