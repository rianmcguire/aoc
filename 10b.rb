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
            [:e, :s]
        when "S"
            [:n, :e, :s, :w].filter do |dir|
                neighbour = pos.step(dir)
                GRID[neighbour.y][neighbour.x].exits.include?(opposite(dir))
            end
        when "."
            []
        end
    end

    def outside(entered_from)
        return [] unless entered_from

        case symbol
        when "|"
            case entered_from
            when :s
                [:w]
            when :n
                [:e]
            else
                []
            end
        when "-"
            case entered_from
            when :e
                [:s]
            when :w
                [:n]
            else
                []
            end
        when "L"
            case entered_from
            when :e
                [:s, :w]
            else
                []
            end
        when "J"
            case entered_from
            when :n
                [:e, :s]
            else
                []
            end
        when "7"
            case entered_from
            when :w
                [:n, :e]
            else
                []
            end
        when "F"
            case entered_from
            when :s
                [:n, :w]
            else
                []
            end
        else
            []
        end
    end
end

grid = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map { |s, x| Cell.new(s, Pos.new(x, y)) }
end
GRID = grid

def valid_pos(pos)
    (0...GRID.first.length).include?(pos.x) && (0...GRID.length).include?(pos.y)
end

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

loop_cells = Set.new
path = bfs(
  source: start,
  adjacent_fn: proc do |node|
    node.exits.map do |dir|
        new_pos = node.pos.step(dir)
        GRID[new_pos.y][new_pos.x]
    end
  end,
  target_fn: ->(node) { loop_cells << node; false },
)
LOOP_CELLS = loop_cells

OUTSIDE = Set.new
def flood(node)
    stack = [node]

    while !stack.empty?
        node = stack.pop

        next if OUTSIDE.include?(node) || LOOP_CELLS.include?(node)

        OUTSIDE << node

        [:n, :e, :s, :w].each do |dir|
            new_pos = node.pos.step(dir)
            next unless valid_pos(new_pos)
            new_node = GRID[new_pos.y][new_pos.x]

            stack << new_node
        end
    end
end

def dump
    GRID.each do |row|
        row.each do |cell|
            if OUTSIDE.include?(cell)
                putc "O"
            elsif LOOP_CELLS.include?(cell)
                putc cell.symbol
            else
                putc "."
            end
        end
        puts
    end
    puts
end

dump


VISITED = Set.new
# def walk_and_fill(node, travel_dir)

#     # putc node.symbol

#     return if node.symbol == "S"

#     node.outside(travel_dir).each do |dir|
#         new_pos = node.pos.step(dir)
#         next unless valid_pos(new_pos)
#         new_node = GRID[new_pos.y][new_pos.x]

#         # if new_node.symbol == "."
#         #     OUTSIDE << new_node
#         # end
#         flood(new_node)
#     end

#     node.exits.each do |dir|
#         new_pos = node.pos.step(dir)
#         new_node = GRID[new_pos.y][new_pos.x]
#         walk_and_fill(new_node, opposite(dir))
#     end

#     # dump
# end



# dump

after_start_pos = start.pos.step(start.exits.first)
after_start_node = GRID[after_start_pos.y][after_start_pos.x]
# walk_and_fill(after_start_node, nil)

stack = [[after_start_node, nil]]
while !stack.empty?
    node, travel_dir = stack.pop

    next unless VISITED.add?(node)

    # putc node.symbol

    node.outside(travel_dir).each do |dir|
        new_pos = node.pos.step(dir)
        next unless valid_pos(new_pos)
        new_node = GRID[new_pos.y][new_pos.x]

        if new_node.symbol == "."
            OUTSIDE << new_node
        end
        flood(new_node)
    end

    node.exits.reverse.each do |dir|
        new_pos = node.pos.step(dir)
        new_node = GRID[new_pos.y][new_pos.x]

        stack.push([new_node, opposite(dir)])
    end
end

puts

dump


total_cells = grid.length * grid.first.length
puts total_cells - OUTSIDE.length - LOOP_CELLS.length
