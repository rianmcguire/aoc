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

robots = ARGF.each_line.flat_map do |line|
  line.scan(/-?\d+/).map(&:to_i).each_slice(2).map { Pos.new(*_1) }.each_slice(2).map { Robot.new(*_1, _1.first) }
end

X_SIZE = robots.map { _1.p.x }.max + 1
Y_SIZE = robots.map { _1.p.y }.max + 1

def display(robots)
  robots_by_pos = Hash.new {|h,k| h[k] = 0}
  robots.each do |r|
    robots_by_pos[r.p] += 1
  end

  (0...Y_SIZE).each do |y|
    (0...X_SIZE).each do |x|
      if robots_by_pos[Pos.new(x,y)] > 0
        putc (robots_by_pos[Pos.new(x,y)].clamp(0..9)).to_s
      else
        putc "."
      end
    end
    puts
  end
end

def max_x_run_length(robots)
  by_row = robots.group_by { _1.p.y }

  by_row.map do |y, row|
    row.map { _1.p.x }.sort.slice_when { |a,b| b != a + 1 }.map { _1.length }.max
  end.max
end

1.step do |i|
  robots.each do |r|
    r.p = (r.p + r.v).wrap
  end

  if max_x_run_length(robots) > 10
    display(robots)
    puts
    puts i
    break
  end
end
