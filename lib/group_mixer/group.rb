require 'set'
require 'forwardable'

module GroupMixer
  class Group
    extend Forwardable

    def initialize(max_size)
      @max_size = max_size
      @members = Set.new
    end

    def_delegators :@members, :size, :each
    attr_reader :members

    def add(member)
      @members.add member unless full?
    end

    def full?
      @members.size == @max_size
    end
  end
end
