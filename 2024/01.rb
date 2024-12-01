#!/usr/bin/env ruby

left = []
right = []
ARGF.each_line do |line|
  a, b = line.split.map(&:to_i)
  left << a
  right << b
end

left.sort!
right.sort!

left.zip(right).map do |l, r|
  (l - r).abs
end.sum.then { puts _1 }
