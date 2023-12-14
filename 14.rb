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

rocks = Set.new
blocks = Set.new

ARGF.each_line.each_with_index do |line, y|
    line.chomp.chars.each_with_index do |c, x|
        if c == "O"
            rocks << Pos.new(x, y)
        elsif c == "#"
            blocks << Pos.new(x, y)
        end
    end
end

max_x = (rocks + blocks).map(&:x).max
$max_y = max_y = (rocks + blocks).map(&:y).max

# Compact a 1D stack of rock indexes towards 0
def compact(rocks, blockers)
    result = []

    blockers.sort!
    [-1, *blockers, $max_y + 1].each_cons(2).map { |a, b| Range.new(a + 1, b, true) }.each do |range|
        count = rocks.count { range.include?(_1) }
        count.times do |x|
            result << range.begin + x
        end
    end

    result
end

(0..max_x).each do |x|
    stack = rocks.filter { _1.x == x }
    blockers = blocks.filter { _1.x == x }

    stack.each { rocks.delete _1 }

    compact(stack.map(&:y), blockers.map(&:y)).each do |y|
        rocks << Pos.new(x, y)
    end
end

(0..max_y).each do |y|
    (0..max_x).each do |x|
        pos = Pos.new(x, y)

        if rocks.include?(pos)
            putc "O"
        elsif blocks.include?(pos)
            putc "#"
        else
            putc "."
        end
    end
    puts
end

rocks.sum do |rock|
    max_y + 1 - rock.y
end.then { puts _1 }
