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

Rock = Struct.new(:blocker?, :n)

# Compact a 1D stack of rock indexes towards the left or right
def compact(rocks, blockers, right)
    objects = [
        *rocks.map { Rock.new(false, _1) },
        *blockers.map { Rock.new(true, _1 ) },
    ].sort_by { _1.n }

    groups = if right
        objects.slice_after { _1.blocker? }
    else
        objects.slice_before { _1.blocker? }
    end

    result = []
    groups.each do |group|
        count = group.count { !_1.blocker? }
        if right
            last_empty = group.filter_map { _1.blocker? && (_1.n - 1) }.first || $max_x
            count.times do |i|
                result << last_empty - i
            end
        else
            first_empty = group.filter_map { _1.blocker? && (_1.n + 1) }.last || 0
            count.times do |i|
                result << first_empty + i
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
