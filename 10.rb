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
            # We don't know what shape start cell is. Infer it from which neighbouring cells join it
            [:n, :s, :e, :w].filter do |dir|
                neighbour = pos.step(dir)
                $grid[neighbour.y][neighbour.x].exits.include?(opposite(dir))
            end
        when "."
            []
        end
    end
end

# Parse grid into Cells
$grid = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map { |s, x| Cell.new(s, Pos.new(x, y)) }
end

def bfs(source:, adjacent_fn:)
    to_explore = [source]
    explored = Set.new([source])
    parent = {}

    while to_explore.any?
      node = to_explore.shift

      adjacent_fn.call(node).each do |child|
        if explored.add?(child)
          parent[child] = node
          to_explore << child
        end
      end
    end

    # Return path back to start when we run of nodes to explore
    path = []
    while node
        path.unshift node
        node = parent[node]
    end
    return path
end

# Explore from the start cell using BFS
start = $grid.flatten.find { |c| c.symbol == "S" }
path = bfs(
  source: start,
  adjacent_fn: proc do |node|
    node.exits.map do |dir|
        new_pos = node.pos.step(dir)
        $grid[new_pos.y][new_pos.x]
    end
  end,
)

# The start cell doesn't count as a step
puts path.length - 1
