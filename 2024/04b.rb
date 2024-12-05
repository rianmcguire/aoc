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

def match?(pos)
  diags = [[pos.step(:sw), pos.step(:ne)], [pos.step(:se), pos.step(:nw)]]

  match = diags.all? do |diag|
    next unless diag.all? { _1.valid? }
    s = diag.map { GRID[_1.y][_1.x] }.join
    s == "SM" || s == "MS"
  end
end

result = 0
GRID.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    next unless cell == "A"

    result += 1 if match?(Pos.new(x, y))
  end
end

puts result
