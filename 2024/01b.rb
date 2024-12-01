#!/usr/bin/env ruby

left = []
right = []
ARGF.each_line do |line|
  a, b = line.split.map(&:to_i)
  left << a
  right << b
end

left.map do |l|
  l * right.count { _1 == l }
end.sum.then { puts _1 }
