#!/usr/bin/env ruby

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
end

GRID = ARGF.each_line.each_with_index.map do |line, y|
  line.chomp.chars.each_with_index do |c, x|
    if c == "S"
      START = Pos.new(x, y)
    end

    c
  end
end

beams = [START]
n_splits = 0
START.y.upto(GRID.length - 1) do |y|
  splitters = GRID[y].each_with_index.filter { |c, x| c == "^" }.map { |c, x| Pos.new(x, y) }
  to_split = beams & splitters
  unsplit = beams - to_split
  
  n_splits += to_split.length
  
  beams = [
    *to_split.flat_map { |b| [b.step(:w), b.step(:e)] },
    *unsplit,
  ].uniq
  
  beams = beams.map { it.step(:s) }
end

puts n_splits
