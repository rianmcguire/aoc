#!/usr/bin/env ruby

Pos = Struct.new(:x, :y)

patterns = []
ARGF.read.split("\n\n").each do |pattern_block|
    pattern = []
    pattern_block.each_line.with_index do |line, y|
        line.chomp.chars.each_with_index do |c, x|
            pos = Pos.new(x, y)
            if c == "#"
                pattern << Pos.new(x, y)
            end
        end
    end
    patterns << pattern
end

def row(pattern, y)
    pattern.filter { _1.y == y }.map(&:x)
end

def col(pattern, x)
    pattern.filter { _1.x == x }.map(&:y)
end

patterns.sum do |pattern|
    max_x = pattern.map(&:x).max
    max_y = pattern.map(&:y).max

    vertical = (0..max_x - 1).find do |x|
        left_size = x
        right_size = max_x - x - 1
        size = [left_size, right_size].min

        (0..size).all? do |offset|
            col(pattern, x - offset) == col(pattern, x + offset + 1)
        end
    end

    if vertical
        vertical += 1
    else
        vertical = 0
    end

    horizontal = (0..max_y - 1).find do |y|
        left_size = y
        right_size = max_y - y - 1
        size = [left_size, right_size].min

        (0..size).all? do |offset|
            row(pattern, y - offset) == row(pattern, y + offset + 1)
        end
    end

    if horizontal
        horizontal += 1
    else
        horizontal = 0
    end

    vertical + 100 * horizontal
end.then { puts _1 }
