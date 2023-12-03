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
asterisks = []
rows.each_with_index do |row,y|
    digit = nil
    row.chars.each_with_index do |c,x|
        if c == "*"
            asterisks << [x, y]
        end

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

gears = []
asterisks.each do |x, y|
    adjacent_digits = digits.filter do |digit|
        digit.coords.any? do |dx, dy|
            adjacent(dx, dy).any? do |dx, dy|
                dx == x && dy == y
            end
        end
    end

    if adjacent_digits.length == 2
        gears << adjacent_digits
    end
end

gears.map do |digits|
    digits.map(&:string).map(&:to_i).reduce(&:*)
end.sum.then { |result| puts result }
