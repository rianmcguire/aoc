#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
    def step(dir, n)
        case dir
        when "U"
            Pos.new(x, y - n)
        when "D"
            Pos.new(x, y + n)
        when "R"
            Pos.new(x + n, y)
        when "L"
            Pos.new(x - n, y)
        end
    end
end

def right_turn?(last_dir, dir)
    (last_dir == "U" && dir == "R") ||
    (last_dir == "R" && dir == "D") ||
    (last_dir == "D" && dir == "L") ||
    (last_dir == "L" && dir == "U")
end

pos = Pos.new(0, 0)
last_dir = nil
poly = [pos]
ARGF.each_line do |line|
    dir, dist, color = line.chomp.split(" ")
    dist = dist.to_i

    if right_turn?(last_dir, dir)
        # If we're making a right turn from the perspective of the digger, we need to trace around the outside
        # of the corner by taking an extra step in the original direction, and the new direction.
        pos = pos.step(last_dir, 1)
        poly << pos

        pos = pos.step(dir, 1)
        poly << pos
    elsif last_dir.nil?
        # Special case for the initial position
        dist = dist + 1
    end

    # Step 1 less than the distance, as what happens at the corner depends on the next direction
    pos = pos.step(dir, dist - 1)
    poly << pos

    last_dir = dir
end

# https://en.wikipedia.org/wiki/Shoelace_formula
def area(poly)
    area = 0
    poly.zip(poly.rotate(1)).each do |a, b|
        area += a.x * b.y
        area -= b.x * a.y
    end
    area.abs / 2
end

puts area(poly)
