#!/usr/bin/env ruby

DIRS = [:n, :e, :s, :w]

def turn_right(dir)
  DIRS[(DIRS.index(dir) + 1) % DIRS.length]
end

Pos = Struct.new(:x, :y) do
  def step(dir)
    case dir
    when :n
      Pos.new(x, y - 1)
    when :s
      Pos.new(x, y + 1)
    when :e
      Pos.new(x + 1, y)
    when :w
      Pos.new(x - 1, y)
    end
  end

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y)
  end

  def obstacle?
    GRID.fetch(y).fetch(x) == '#'
  end
end

start = nil
dir = :n
GRID = ARGF.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    if c == '^'
      start = Pos.new(x,y)
      '.'
    else
      c
    end
  end
end

Y_RANGE = 0...GRID.length
X_RANGE = 0...GRID.first.length

visited = Set.new
pos = start
loop do
  visited << pos

  next_pos = pos.step(dir)
  break if !next_pos.valid?

  if next_pos.obstacle?
    dir = turn_right(dir)
  else
    pos = next_pos
  end
end

puts visited.length
