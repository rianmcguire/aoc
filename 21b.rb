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
        GRID[y % (Y_RANGE.max + 1)][x % (X_RANGE.max + 1)] != "#"
    end
end

DIRS = [:n, :s, :e, :w]

target_step = if ARGV.length > 1
    ARGV.pop.to_i
else
    26501365
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

def try_project(series, target_length)
    # Try possible period lengths
    (1..200).each do |period|
        # Get every nth element in the series, stepping back from the latest
        every_nth = (series.length - 1).step(0, -period).map { |i| series[i] }.reverse

        # If the second derivative is constant, we've found a fit
        first_deriv = every_nth.each_cons(2).map { |a, b| b - a }
        second_deriv = first_deriv.each_cons(2).map { |a, b| b - a }
        next unless second_deriv.length >= 2 && second_deriv.uniq.length == 1

        # Wait until the distance to the target is an exact multiple the period
        next unless (target_length - series.length) % period == 0

        periods = (target_length - series.length) / period

        # Every period, the first derivative grows by the second derivative.
        #
        # So to project 4 periods, we need to add:
        # + the current last value
        # + first_deriv * 4
        # + second_deriv * 1 (for the first period)
        # + second_deriv * 2 (for the second period)
        # + second_deriv * 3 (for the third period)
        # + second_deriv * 4 (for the forth period)
        #
        # The number of second_derivs we need to add for n periods follows the sequence (1, 1+2, 1+2+3, 1+2+3+4) =
        # (1, 3, 6, 10), which is trangular_number(n) = n * (n + 1) / 2 (https://en.wikipedia.org/wiki/Triangular_number)
        return series.last + first_deriv.last * periods + second_deriv.last * (periods * (periods + 1) / 2)
    end

    nil
end

positions = Set.new([starting_pos])
totals = []
loop do
    new_positions = Set.new
    positions.each do |pos|
        DIRS.each do |dir|
            new_pos = pos.step(dir)
            next unless new_pos.valid?

            new_positions << new_pos
        end
    end

    positions = new_positions

    totals << positions.length
    result = try_project(totals, target_step)
    if result
        puts result
        break
    end
end
