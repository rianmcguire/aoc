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
max_y = (rocks + blocks).map(&:y).max

loop do
    any_moved = false
    (1..max_y).each do |y|
        rocks.filter { _1.y == y }.each do |rock|
            new_rock = rock.step(:n)

            if !rocks.include?(new_rock) && !blocks.include?(new_rock)
                rocks.delete rock
                rocks << new_rock
                any_moved = true
            end
        end
    end

    break unless any_moved
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
