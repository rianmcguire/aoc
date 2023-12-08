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
    # All the coodinates containing the digit string
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
rows.each_with_index do |row,y|
    digit = nil
    row.chars.each_with_index do |c,x|
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

digits.filter do |digit|
    # Find all digits where any of the coodinates are adjacent to a non-digit, non-"." character
    digit.coords.any? do |coord|
        coord.adjacent.any? do |coord|
            rows[coord.y][coord.x].match(/[^\.\d]/)
        end
    end
end.map(&:value).sum.then { puts _1 }
