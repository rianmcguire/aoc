#!/usr/bin/env ruby

rocks_by = {
    x: Hash.new { |h, k| h[k] = [] },
    y: Hash.new { |h, k| h[k] = [] },
}
blocks_by = {
    x: Hash.new { |h, k| h[k] = [] },
    y: Hash.new { |h, k| h[k] = [] },
}

lines = ARGF.each_line.map(&:chomp)
lines.each_with_index do |line, y|
    line.chars.each_with_index do |c, x|
        if c == "O"
            rocks_by[:x][x] << y
            rocks_by[:y][y] << x
        elsif c == "#"
            blocks_by[:x][x] << y
            blocks_by[:y][y] << x
        end
    end
end

$max_y = max_y = lines.length - 1
$max_x = max_x = lines.first.length - 1

$known_states = {}

# Compact a 1D stack of rock indexes towards the left or right
def compact(rocks, blockers, right)
    result = []

    # TODO: pre-sort on load
    blockers.sort!

    [-1, *blockers, $max_y + 1].each_cons(2).map { |a, b| Range.new(a + 1, b - 1, false) }.each do |range|
        # TODO: take advantage of rocks being sorted
        count = rocks.count { range.include?(_1) }
        count.times do |x|
            if right
                result << range.end - x
            else
                result << range.begin + x
            end
        end
    end

    result
end

cycles = 1000000000
cycle = 0
loop do
    cycle += 1
    [:n, :w, :s, :e].each do |dir|
        range, axis, opposite_axis, reverse = case dir
        when :n 
            [(0..max_x), :x, :y, false]
        when :s
            [(0..max_x), :x, :y, true]
        when :e
            [(0..max_y), :y, :x, true]
        when :w
            [(0..max_y), :y, :x, false]
        end

        range.each do |n|
            rocks = rocks_by[axis][n]
            rocks.each do |j|
                rocks_by[opposite_axis][j].delete n
            end

            new_rocks = compact(rocks, blocks_by[axis][n], reverse)

            rocks_by[axis][n] = new_rocks
            new_rocks.each do |j|
                # TODO: insert sorted
                rocks_by[opposite_axis][j] << n
            end
        end
    end

    state = rocks_by[:x].values.map { _1.dup }

    if prev = $known_states[state]
        repeat_length = cycle - prev
        remaining = cycles - cycle
        skip_repeats = remaining / repeat_length
        cycle += skip_repeats * repeat_length
        $known_states = {}
    else
        $known_states[state] = cycle
    end

    break if cycle == cycles
end

rocks_by[:x].values.sum do |ys|
    ys.sum do |y|
        max_y + 1 - y
    end
end.then { puts _1 }
