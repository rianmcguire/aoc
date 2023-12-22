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
        GRID[n_pos.y][n_pos.x] != "#"
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

target_step = 26501365
# I observed that after a certain point, the number of positions grows by a predictable amount every 131 steps.
# TODO: automatically detect this period
period = 131

step = 0
last_total = 0
last_delta = 0
last_delta_delta = 0
loop do
    step += 1

    new_positions = Set.new
    positions.each do |pos|
        DIRS.each do |dir|
            new_pos = pos.step(dir)
            next unless new_pos.valid?

            new_positions << new_pos
        end
    end

    positions = new_positions

    if ((target_step - step) % period == 0)
        puts "#{step}"
        total = positions.length
        delta = total - last_total
        delta_delta = delta - last_delta
        puts "total: #{total} delta #{delta}, delta delta #{delta_delta}"

        if delta_delta == last_delta_delta
            # We have enough information to project from here
            periods = (target_step - step) / period
            puts total + delta * periods + delta_delta * (periods * (periods + 1) / 2)
            break
        end

        last_total = total
        last_delta = delta
        last_delta_delta = delta_delta
    end
end
