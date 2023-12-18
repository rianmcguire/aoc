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

lines = ARGF.each_line.to_a

def rotation(last_dir, dir)
    if last_dir == "U" && dir == "R"
        90
    elsif last_dir == "U" && dir == "L"
        -90
    elsif last_dir == "D" && dir == "L"
        90
    elsif last_dir == "D" && dir == "R"
        -90
    elsif last_dir == "R" && dir == "U"
        -90
    elsif last_dir == "R" && dir == "D"
        90
    elsif last_dir == "L" && dir == "U"
        90
    elsif last_dir == "L" && dir == "D"
        -90
    else
        0
    end
end

# Polygon
pos = Pos.new(0, 0)
last_dir = nil
poly = [pos]
lines.each do |line|
    puts line
    _, _, color = line.chomp.split(" ")

    color = color[2..]

    dist_hex = color[...5]
    dist = dist_hex.to_i(16)
    dir = ["R", "D", "L", "U"][color[5].to_i]

    rot = rotation(last_dir, dir)
    puts "rot #{rot}"
    if rot > 0
        pos = pos.step(last_dir, 1)
        poly << pos
        pp pos

        pos = pos.step(dir, 1)
        poly << pos
        pp pos
    elsif last_dir.nil?
        dist = dist + 1
    end

    pos = pos.step(dir, dist - 1)
    poly << pos
    pp pos

    last_dir = dir
end


# https://en.wikipedia.org/wiki/Shoelace_formula
def area(poly)
    area = 0
    poly.zip(poly.rotate(1)).each do |a, b|
        area += a.x * b.y
        area -= b.x * a.y
    end
    area.abs / 2.0
end

puts "Shoelace area: #{area(poly)}"
