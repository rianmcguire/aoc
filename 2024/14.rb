#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def +(b)
    Pos.new(x + b.x, y + b.y)
  end

  def wrap
    Pos.new(x % X_SIZE, y % Y_SIZE)
  end
end
Robot = Struct.new(:p, :v, :initial)

# X_SIZE = 11
# Y_SIZE = 7
X_SIZE = 101
Y_SIZE = 103

robots = ARGF.each_line.flat_map do |line|
  line.scan(/-?\d+/).map(&:to_i).each_slice(2).map { Pos.new(*_1) }.each_slice(2).map { Robot.new(*_1, _1.first) }
end

looped = Set.new
100.times do
  robots.each do |r|
      r.p = (r.p + r.v).wrap
  end
end

xs = [(0...(X_SIZE / 2)), ((X_SIZE - (X_SIZE / 2))...X_SIZE)]
ys = [(0...(Y_SIZE / 2)), ((Y_SIZE - (Y_SIZE / 2))...Y_SIZE)]
quads = Enumerator.product(xs, ys)

quads.map do |x_range, y_range|
  robots.filter { x_range.include?(_1.p.x) && y_range.include?(_1.p.y) }.count
end.reduce(:*).then { puts _1 }
