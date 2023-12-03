#!/usr/bin/env ruby

rows = ARGF.each_line.map do |line|
    line.chomp
end
$rows = rows

Digit = Struct.new(:x, :y, :string, keyword_init: true) do
    def coords
        (0...string.length).map do |x_offset|
            [x + x_offset, y]
        end
    end
end

def adjacent(x, y)
    [
        [x-1, y],
        [x+1, y],
        [x, y-1],
        [x, y+1],
        [x-1, y+1],
        [x+1, y-1],
        [x+1, y+1],
        [x-1, y-1],
    ].filter { |x, y| in_range(x,y) }
end

def in_range(x, y)
    y >= 0 && y < $rows.length && x >= 0 && x < $rows.first.length
end

digits = []
rows.each_with_index do |row,y|
    digit = nil
    row.chars.each_with_index do |c,x|
        if c.match /\d/
            if !digit
                digit = Digit.new(x: x, y: y, string: "")
                digits << digit
            end
            digit.string += c
        else
            digit = nil
        end
    end
end

digits.filter do |digit|
    digit.coords.any? do |x, y|
        adjacent(x, y).any? do |x, y|
            rows[y][x].match(/[^\.0-9]/)
        end
    end
end.map do |digit|
    digit.string.to_i
end.sum.then { |r| puts r }
