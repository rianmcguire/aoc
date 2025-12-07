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

beams = [START]
n_splits = 0
ROWS.length.times do |y|
  splitters = ROWS[y]
  to_split, unsplit = beams.partition { |b| splitters.include?(b) }

  n_splits += to_split.length

  beams = [
    *to_split.flat_map { |b| [b.step(:w), b.step(:e)] },
    *unsplit,
  ].uniq

  beams = beams.map { it.step(:s) }
end

puts n_splits
