#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def +(b)
    Pos.new(x + b.x, y + b.y)
  end

  def -(b)
    Pos.new(x - b.x, y - b.y)
  end

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y)
  end
end

antennas = Hash.new { |h,k| h[k] = [] }

GRID = ARGF.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    if c != "."
      antennas[c] << Pos.new(x,y)
    end
    c
  end
end

Y_RANGE = 0...GRID.length
X_RANGE = 0...GRID.first.length

antinodes = Set.new

antennas.each do |freq, nodes|
  nodes.combination(2).each do |a, b|
    vec = a - b

    x = a
    while x.valid?
      antinodes << x
      x += vec
    end

    x = a
    while x.valid?
      antinodes << x
      x -= vec
    end
  end
end

puts antinodes.size
