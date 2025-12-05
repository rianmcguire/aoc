#!/usr/bin/env ruby

GRID = ARGF.each_line.map do |row|
  row.chomp.chars
end

MAX_X = GRID.first.length - 1
MAX_Y = GRID.length - 1

Coord = Struct.new(:x, :y) do
    # All valid adjacent coords (including diagonals)
    def adjacent
        [].tap do |result|
            result << Coord.new(x-1, y) if x > 0
            result << Coord.new(x+1, y) if x < MAX_X
            result << Coord.new(x, y-1) if y > 0
            result << Coord.new(x, y+1) if y < MAX_Y
            result << Coord.new(x-1, y+1) if x > 0 && y < MAX_Y
            result << Coord.new(x+1, y-1) if x < MAX_Y && y > 0
            result << Coord.new(x+1, y+1) if x < MAX_X && y < MAX_Y
            result << Coord.new(x-1, y-1) if x > 0 && y > 0
        end
    end
end

result = 0

GRID.each_with_index do |row, y|
  row.each_with_index do |c, x|
    next unless c == "@"
    n = Coord.new(x, y).adjacent.count { |a| GRID[a.y][a.x] == "@" }
    result += 1 if n < 4
  end
end

puts result
