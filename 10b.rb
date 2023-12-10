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
            # We don't know what shape start cell is. Infer it from which neighbouring cells join it
            [:n, :e, :s, :w].filter do |dir|
                neighbour = pos.step(dir)
                $grid[neighbour.y][neighbour.x].exits.include?(opposite(dir))
            end
        when "."
            []
        end
    end

    # In which direction(s) is the inside of the loop from this cell, assuming we're travelling anti-clockwise
    # ie. which direction(s) are to the left-hand side when travelling anti-clockwise?
    def inside(entered_from)
        return [] unless entered_from

        case symbol
        when "|"
            case entered_from
            when :n
                [:e]
            when :s
                [:w]
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

$grid = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map { |s, x| Cell.new(s, Pos.new(x, y)) }
end

def valid_pos(pos)
    (0...$grid.first.length).include?(pos.x) && (0...$grid.length).include?(pos.y)
end

start = $grid.flatten.find { |c| c.symbol == "S" }

def walk(start, reverse)
    cell, entered_from = start, start.exits[reverse ? 1 : 0]
    loop do
        yield cell, entered_from

        # Exit out the direction we didn't enter from
        exit_dir = (cell.exits - [entered_from]).first
        new_pos = cell.pos.step(exit_dir)
        cell = $grid[new_pos.y][new_pos.x]
        entered_from = opposite(exit_dir)

        # We've reached the start again
        break if cell.symbol == "S"
    end
end

# Walk the loop
path = []
walk(start, false) do |cell, entered_from|
    path << cell
end
$loop = Set.new(path)

# Determine if the walk we did was clockwise or anti-clockwise
# https://en.wikipedia.org/wiki/Curve_orientation#Practical_considerations

# Select a vertex on the convex hull of the polygon: "A common choice is the vertex of the polygon with the smallest
# X-coordinate. If there are several of them, the one with the smallest Y-coordinate is picked."
b_index = path.each_with_index.sort_by { |cell, i| [cell.pos.x, cell.pos.y] }.first.last

# Determine the sign of the angle ABC, where A and C are the vertices before/after the one we selected
a = path[b_index - 1].pos
b = path[b_index].pos
c = path[b_index + 1].pos
determinant = (b.x - a.x) * (c.y - a.y) - (c.x - a.x) * (b.y - a.y)

# We need to walk in the anti-clockwise direction so the inside is always on our "left" - reverse if needed
reverse = determinant > 0

# Flood fill from every inside node reachable from the loop
$inside = Set.new
def flood(cell)
    stack = [cell]

    until stack.empty?
        cell = stack.pop

        # Fill all reachable cells, except if they're already filled, or they're part of the loop
        next if $inside.include?(cell) || $loop.include?(cell)

        $inside << cell

        [:n, :e, :s, :w].each do |dir|
            new_pos = cell.pos.step(dir)
            next unless valid_pos(new_pos)
            new_cell = $grid[new_pos.y][new_pos.x]

            stack << new_cell
        end
    end
end
walk(start, reverse) do |cell, entered_from|
    cell.inside(entered_from).each do |dir|
        new_pos = cell.pos.step(dir)
        next unless valid_pos(new_pos)
        flood($grid[new_pos.y][new_pos.x])
    end
end

$grid.each do |row|
    row.each do |cell|
        if $inside.include?(cell)
            putc "I"
        elsif $loop.include?(cell)
            putc cell.symbol
        else
            putc "."
        end
    end
    puts
end
puts

puts $inside.length
