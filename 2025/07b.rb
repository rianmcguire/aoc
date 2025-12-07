#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
  def step(dir)
      case dir
      when :s
          Pos.new(x, y + 1)
      when :e
          Pos.new(x + 1, y)
      when :w
          Pos.new(x - 1, y)
      end
  end
end

ROWS = []
ARGF.each_line.each_with_index do |line, y|
  if sx = line.index("S")
    START = Pos.new(sx, y)
  end

  ROWS << line.chomp.chars.each_with_index.filter { |c, x| c == "^" }.map { |c, x| Pos.new(x, y) }
end

def dfs(beam, memo = {})
  memo[beam] ||= (
    y = beam.y

    # Base case: we've reached the bottom
    return 1 if y == ROWS.length - 1

    if ROWS[y].include?(beam)
      # The beam hit a splitter - search left and right
      [beam.step(:w), beam.step(:e)].sum do |b|
        dfs(b.step(:s), memo)
      end
    else
      # Beam continues straight
      dfs(beam.step(:s), memo)
    end
  )
end

puts dfs(START)
