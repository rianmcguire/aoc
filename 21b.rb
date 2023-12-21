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

    def normalize
        Pos.new(x % (X_RANGE.max + 1), y % (Y_RANGE.max + 1))
    end

    def valid?
        n_pos = normalize
        (GRID[n_pos.y][n_pos.x] == "." || GRID[n_pos.y][n_pos.x] == "S")
    end

    def frame
        [x / (X_RANGE.max + 1), y / (Y_RANGE.max + 1)]
    end

    def frame_shift(frame)
        Pos.new(x - frame[0] * (X_RANGE.max + 1), y - frame[1] * (Y_RANGE.max + 1))
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

positions = Set.new([starting_pos])

100.times do |step|
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

pp positions.length
