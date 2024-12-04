#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def step(dir)
      case dir
      when "n"
          Pos.new(x, y - 1)
      when "s"
          Pos.new(x, y + 1)
      when "e"
          Pos.new(x + 1, y)
      when "w"
          Pos.new(x - 1, y)
      when "ne"
          Pos.new(x + 1, y - 1)
      when "nw"
          Pos.new(x - 1, y - 1)
      when "se"
          Pos.new(x + 1, y + 1)
      when "sw"
          Pos.new(x - 1, y + 1)
      end
  end

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y)
  end
end

grid = ARGF.each_line.map do |row|
  row.chomp.chars
end

Y_RANGE = 0...grid.length
X_RANGE = 0...grid.first.length

DIRS = %w(n s e w ne nw se sw)

TARGET = "XMAS"

result = 0
grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    next unless cell == "X"

    start = Pos.new(x, y)

    DIRS.each do |dir|
      pos = start
      string = ""
      while pos.valid?
        string += grid[pos.y][pos.x]
        break if string == TARGET || !TARGET.start_with?(string)
        pos = pos.step(dir)
      end

      if string == TARGET
        result += 1
      end
    end
  end
end

puts result
