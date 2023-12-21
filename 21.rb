#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
    def step(dir)
        case dir
        when :n
            Pos.new(x, y - 1)
        when :s
            Pos.new(x, y + 1)
        when :e
            Pos.new(x + 1, y)
        when :w
            Pos.new(x - 1, y)
        end
    end

    def valid?
        X_RANGE.include?(x) && Y_RANGE.include?(y) && (GRID[y][x] == "." || GRID[y][x] == "S")
    end
end

DIRS = [:n, :s, :e, :w]

starting_pos = nil
GRID = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        if c == "S"
            starting_pos = Pos.new(x, y)
        end
        c
    end
end

Y_RANGE = (0..GRID.length - 1)
X_RANGE = (0..GRID.first.length - 1)

def bfs(source:, adjacent_fn:, target_fn:)
    to_explore = [source]
    explored = Set.new([source])
    parent = {}

    while node = to_explore.shift
      if target_fn.call(node)
        path = []
        while node
          path.unshift node
          node = parent[node]
        end
        return path
      end

      adjacent_fn.call(node).each do |child|
        if explored.add?(child)
          parent[child] = node
          to_explore << child
        end
      end
    end

    nil
end

State = Struct.new(:depth, :pos)

TARGET = 64
matching = []
bfs(
    source: State.new(0, starting_pos),
    adjacent_fn: proc do |state|
        next [] if state.depth > TARGET

        DIRS.filter_map do |dir|
            new_pos = state.pos.step(dir)
            next unless new_pos.valid?
            
            State.new(state.depth + 1, new_pos)
        end
    end,
    target_fn: proc do |state|
        if state.depth == TARGET
            matching << state
        end

        false
    end,
)

pp matching.length
