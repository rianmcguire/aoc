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

    # def label
    #     "\"#{x}_#{y}\""
    # end
end

start = Pos.new(GRID.first.index("."), 0)
target = Pos.new(GRID.last.index("."), GRID.length - 1)

def adjacent_fn(pos)
    result = []

    DIRS.each do |dir|
        new_pos = pos.step(dir)
        next unless X_RANGE.include?(new_pos.x) && Y_RANGE.include?(new_pos.y)

        current_cell = GRID[pos.y][pos.x]
        new_cell = GRID[new_pos.y][new_pos.x]
        if new_cell == "#"
            next
        else
            result << new_pos
        end
    end

    result
end

# Vertices are the start, target, and every cell that isn't just a corridor (ie. it has more than 2 adjacent cells)
vertices = {}
GRID.each_with_index do |row, y|
    row.each_with_index do |cell, x|
        next if cell == "#"
        pos = Pos.new(x, y)
        if pos == start || pos == target || adjacent_fn(pos).length > 2
            vertices[pos] = []
        end
    end
end

def dfs_max_weight(start:, adjacent_fn:, target_fn:)
    stack = [[start, {start => 0}]]
    max_weight = nil

    while (node, path = stack.pop)
        if target_fn.call(node)
            weight = path.values.sum
            if !max_weight || weight > max_weight
                max_weight = weight
            end
        end
    
        adjacent_fn.call(node).filter_map do |child, weight|
            next if path.include?(child)
    
            new_path = path.dup
            new_path[child] = weight
            stack.push([child, new_path])
        end
    end

    max_weight
end

Edge = Struct.new(:target, :weight)

# For every combination of vertices, we consider them connected by an edge if there exists a path between them that
# doesn't go through another vertex. The edges are weighted by the length of that path.
vertices.keys.combination(2).each do |a, b|
    max_length = dfs_max_weight(
        start: a,
        adjacent_fn: proc do |pos|
            result = []

            DIRS.each do |dir|
                new_pos = pos.step(dir)
                next unless X_RANGE.include?(new_pos.x) && Y_RANGE.include?(new_pos.y)
                next if vertices.include?(new_pos) && new_pos != b
        
                current_cell = GRID[pos.y][pos.x]
                new_cell = GRID[new_pos.y][new_pos.x]
                if new_cell == "#"
                    next
                else
                    result << [new_pos, 1]
                end
            end
        
            result
        end,
        target_fn: proc do |pos, cost|
            pos == b
        end
    )

    if max_length
        vertices[a] << Edge.new(b, max_length)
        vertices[b] << Edge.new(a, max_length)
    end
end

# already_output = Set.new
# puts "graph G {"
# vertices.each do |v, edges|
#     if v == start || v == target
#         puts "#{v.label} [shape=box];"
#     end
#     edges.each do |e|
#         if already_output.add?([v, e.target]) && already_output.add?([e.target, v])
#             puts "#{v.label} -- #{e.target.label} [label=#{e.weight}];"
#         end
#     end
# end
# puts "}"

# Search the new simpified graph for the maximum weighted path
dfs_max_weight(
    start: start,
    adjacent_fn: proc do |pos|
        vertices[pos].map(&:to_a)
    end,
    target_fn: proc do |pos, cost|
        pos == target
    end
).then { puts _1 }
