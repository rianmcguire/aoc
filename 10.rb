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
end

def opposite(dir)
    case dir
    when :n
        :s
    when :s
        :n
    when :e
        :w
    when :w
        :e
    end
end

Cell = Struct.new(:symbol, :pos) do
    def exits
        case symbol
        when "|"
            [:n, :s]
        when "-"
            [:e, :w]
        when "L"
            [:n, :e]
        when "J"
            [:n, :w]
        when "7"
            [:s, :w]
        when "F"
            [:s, :e]
        when "S"
            [:n, :s, :e, :w].filter do |dir|
                neighbour = pos.step(dir)
                GRID[neighbour.y][neighbour.x].exits.include?(opposite(dir))
            end
        when "."
            []
        end
    end
end

grid = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map { |s, x| Cell.new(s, Pos.new(x, y)) }
end
GRID = grid

start = grid.flatten.find { |c| c.symbol == "S" }


def bfs(source:, adjacent_fn:, target_fn:)
    to_explore = [source]
    explored = Set.new([source])
    parent = {}

    while to_explore.any?
      node = to_explore.shift
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

    path = []
    while node
        path.unshift node
        node = parent[node]
    end
    return path
end

visited = Set.new
path = bfs(
  source: start,
  adjacent_fn: proc do |node|
    node.exits.map do |dir|
        new_pos = node.pos.step(dir)
        GRID[new_pos.y][new_pos.x]
    end
  end,
  target_fn: ->(node) { false },
)

puts path.length - 1
