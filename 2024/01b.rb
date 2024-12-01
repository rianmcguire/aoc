#!/usr/bin/env ruby

left = []
right = []
ARGF.each_line do |line|
  a, b = line.split.map(&:to_i)
  left << a
  right << b
end

right_counts = right.tally

left.sum do |l|
  l * right_counts.fetch(l, 0)
end.then { puts _1 }
