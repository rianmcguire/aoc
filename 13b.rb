#!/usr/bin/env ruby

Pos = Struct.new(:x, :y)

patterns = []
raw_patterns = []
ARGF.read.split("\n\n").each do |pattern_block|
    raw_patterns << pattern_block
    pattern = Set.new
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
    pattern.filter { _1.y == y }.map(&:x).sort
end

def col(pattern, x)
    pattern.filter { _1.x == x }.map(&:y).sort
end

Lor = Struct.new(:dir, :n) do
    def value
        if dir == "v"
            n
        else
            n * 100
        end
    end
end

def find_lor(pattern)
    max_x = pattern.map(&:x).max
    max_y = pattern.map(&:y).max
    
    result = []

    (0..max_x - 1).filter do |x|
        left_size = x
        right_size = max_x - x - 1
        size = [left_size, right_size].min

        (0..size).all? do |offset|
            col(pattern, x - offset) == col(pattern, x + offset + 1)
        end
    end.each do |x|
        result << Lor.new("v", x + 1)
    end

    (0..max_y - 1).filter do |y|
        left_size = y
        right_size = max_y - y - 1
        size = [left_size, right_size].min

        (0..size).all? do |offset|
            row(pattern, y - offset) == row(pattern, y + offset + 1)
        end
    end.each do |y|
        result << Lor.new("h", y + 1)
    end

    result
end

def search(pattern)
    original = find_lor(pattern).first

    max_x = pattern.map(&:x).max
    max_y = pattern.map(&:y).max

    (0..max_x).each do |x|
        (0..max_y).each do |y|
            pos = Pos.new(x, y)

            modified = pattern.dup
            if modified.include?(pos)
                modified.delete pos
            else
                modified.add pos
            end

            lor = (find_lor(modified) - [original]).first
            return lor if lor
        end
    end

    raise "wtf"
end

patterns.each_with_index.sum do |pattern, index|
    search(pattern).value
end.then { puts _1 }
