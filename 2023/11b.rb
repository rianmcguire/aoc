#!/usr/bin/env ruby

Pos = Struct.new(:x, :y)
Galaxy = Struct.new(:pos)
EXPAND = 999999

galaxies = []
ARGF.each_line.with_index do |line, y|
    line.chomp.chars.each_with_index do |c, x|
        pos = Pos.new(x, y)
        if c == "#"
            galaxies << Galaxy.new(pos)
        end
    end
end

max_x = galaxies.map { |g| g.pos.x }.max
max_y = galaxies.map { |g| g.pos.y }.max

y = 0
loop do
    break if y > max_y

    if galaxies.none? { _1.pos.y == y }
        galaxies.filter { _1.pos.y > y }.each do |g|
            g.pos.y += EXPAND
        end
        max_y += EXPAND
        y += EXPAND
    end
    y += 1
end

x = 0
loop do
    break if x > max_x

    if galaxies.none? { _1.pos.x == x }
        galaxies.filter { _1.pos.x > x }.each do |g|
            g.pos.x += EXPAND
        end
        max_x += EXPAND
        x += EXPAND
    end
    x += 1
end

galaxies.combination(2).map do |a, b|
    (a.pos.x - b.pos.x).abs + (a.pos.y - b.pos.y).abs
end.sum.then { puts _1 }
