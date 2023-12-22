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
        X_RANGE.include?(x) && Y_RANGE.include?(y) && (GRID[y][x] != "#")
    end
end

DIRS = [:n, :s, :e, :w]

target_step = if ARGV.length > 1
    ARGV.pop.to_i
else
    64
end

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

positions = Set.new([starting_pos])
target_step.times do
    new_positions = Set.new
    positions.each do |pos|
        DIRS.each do |dir|
            new_pos = pos.step(dir)
            next unless new_pos.valid?

            new_positions << new_pos
        end
    end

    positions = new_positions
end

puts positions.length
