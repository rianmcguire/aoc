#!/usr/bin/env ruby

DIRS = %i(n s e w ne nw se sw)

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
    when :ne
      Pos.new(x + 1, y - 1)
    when :nw
      Pos.new(x - 1, y - 1)
    when :se
      Pos.new(x + 1, y + 1)
    when :sw
      Pos.new(x - 1, y + 1)
    end
  end

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y)
  end
end

GRID = ARGF.each_line.map do |row|
  row.chomp.chars
end

Y_RANGE = 0...GRID.length
X_RANGE = 0...GRID.first.length

TARGET = "XMAS"

def match?(pos, dir)
  string = ""
  while pos.valid?
    string += GRID[pos.y][pos.x]
    return false unless TARGET.start_with?(string)
    return true if string == TARGET
    pos = pos.step(dir)
  end

  false
end

result = 0
GRID.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    next unless cell == "X"

    DIRS.each do |dir|
      result += 1 if match?(Pos.new(x, y), dir)
    end
  end
end

puts result
