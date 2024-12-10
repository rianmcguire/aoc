#!/usr/bin/env ruby

DIRS = [:n, :e, :s, :w]

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
end

starts = []
GRID = ARGF.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    c = c.to_i
    if c == 0
      starts << Pos.new(x,y)
    end
    c
  end
end

Y_RANGE = 0...GRID.length
X_RANGE = 0...GRID.first.length

def search(pos)
  h = GRID[pos.y][pos.x]

  return pos if h == 9

  DIRS.flat_map do |dir|
    new_pos = pos.step(dir)
    next unless new_pos.valid?
    next unless GRID[new_pos.y][new_pos.x] == h + 1

    search(new_pos)
  end.compact.uniq
end

starts.sum do |pos|
  search(pos).length
end.then { puts _1 }
