#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def area(b)
    a = self
    ((a.x - b.x).abs + 1) * ((a.y - b.y).abs + 1)
  end
end

tiles = ARGF.each_line.map do |line|
  Pos.new(*line.split(",").map(&:to_i))
end

puts tiles.combination(2).map { |a, b| a.area(b) }.max
