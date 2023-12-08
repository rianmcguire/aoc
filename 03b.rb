#!/usr/bin/env ruby

rows = ARGF.each_line.map do |line|
    line.chomp
end
MAX_X = rows.first.length - 1
MAX_Y = rows.length - 1

Coord = Struct.new(:x, :y) do
    # All valid adjacent coords (including diagonals)
    def adjacent
        Enumerator.new do |yielder|
            yielder << Coord.new(x-1, y) if x > 0
            yielder << Coord.new(x+1, y) if x < MAX_X
            yielder << Coord.new(x, y-1) if y > 0
            yielder << Coord.new(x, y+1) if y < MAX_Y
            yielder << Coord.new(x-1, y+1) if x > 0 && y < MAX_Y
            yielder << Coord.new(x+1, y-1) if x < MAX_Y && y > 0
            yielder << Coord.new(x+1, y+1) if x < MAX_X && y < MAX_Y
            yielder << Coord.new(x-1, y-1) if x > 0 && y > 0
        end
    end
end

Digit = Struct.new(:start, :string, keyword_init: true) do
    def coords
        (0...string.length).map do |x_offset|
            Coord.new(start.x + x_offset, start.y)
        end
    end

    def value
        string.to_i
    end
end

# Parse digits ("part numbers") into Digit structs with starting location and string value
digits = []
# Also track the coodinates of any "*" characters ("gears")
asterisks = []
rows.each_with_index do |row,y|
    digit = nil
    row.chars.each_with_index do |c,x|
        if c == "*"
            asterisks << Coord.new(x, y)
        end

        if c.match /\d/
            if !digit
                digit = Digit.new(start: Coord.new(x, y), string: "")
                digits << digit
            end
            digit.string += c
        else
            digit = nil
        end
    end
end

# A gear is any * symbol that is adjacent to exactly two part numbers. Its gear ratio is the result of multiplying
# those two numbers together.
#
# Check each asterisk to see if it's adjacent to exactly 2 digits
ratios = []
asterisks.each do |asterisk|
    adjacent_digits = digits.filter do |digit|
        digit.coords.any? do |coord|
            coord.adjacent.include?(asterisk)
        end
    end

    if adjacent_digits.length == 2
        ratios << adjacent_digits.map(&:value).reduce(:*)
    end
end

puts ratios.sum
