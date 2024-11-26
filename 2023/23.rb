#!/usr/bin/env ruby

GRID = ARGF.each_line.each_with_index.map do |line, index|
    line.chomp.chars
end

Y_RANGE = (0..GRID.length - 1)
X_RANGE = (0..GRID.first.length - 1)
DIRS = [:n, :s, :e, :w]

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

start = Pos.new(GRID.first.index("."), 0)
target = Pos.new(GRID.last.index("."), GRID.length - 1)

def dfs(start:, adjacent_fn:, target_fn:)
    stack = [[start, Set.new([start])]]
    lengths = []

    while (node, path = stack.pop)
        if target_fn.call(node)
            lengths << path.length - 1
        end
    
        adjacent_fn.call(node).filter_map do |child|
            next if path.include?(child)

            new_path = path.dup
            new_path << child
            stack.push([child, new_path])
        end
    end

    lengths.max
end

SLOPES = {
    ">" => :e,
    "<" => :w,
    "v" => :s,
}

def adjacent_fn(pos)
    result = []

    DIRS.each do |dir|
        new_pos = pos.step(dir)
        next unless X_RANGE.include?(new_pos.x) && Y_RANGE.include?(new_pos.y)

        current_cell = GRID[pos.y][pos.x]
        new_cell = GRID[new_pos.y][new_pos.x]
        if new_cell == "#"
            next
        elsif SLOPES.include?(new_cell) && SLOPES[new_cell] != dir
            next
        elsif SLOPES.include?(current_cell) && SLOPES[current_cell] != dir
            next
        else
            result << new_pos
        end
    end

    result
end

pp dfs(
    start:,
    adjacent_fn: method(:adjacent_fn),
    target_fn: proc do |pos, cost|
        pos == target
    end
)
