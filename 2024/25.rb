#!/usr/bin/env ruby

chunks = ARGF.read.split("\n\n")

locks = []
keys = []
chunks.each do |chunk|
  lines = chunk.each_line(chomp: true).to_a

  counts_by_col = Array.new(5, -1)
  lines.each do |line|
    line.chars.each_with_index do |c, i|
      counts_by_col[i] += 1 if c == "#"
    end
  end

  if lines.first == "#####"
    locks << counts_by_col
  else
    keys << counts_by_col
  end
end

Enumerator::Product.new(locks, keys).count do |l, k|
  l.zip(k).all? { |l, k| l + k <= 5 }
end.then { puts _1 }
