#!/usr/bin/env ruby

grid = ARGF.each_line.map do |line|
  line.split
end

x_length = grid[0].length
y_length = grid.length

result = x_length.times.sum do |x|
  nums = (y_length - 1).times.map { |y| grid[y][x].to_i }
  op = grid[y_length - 1][x].to_sym
  nums.reduce(&op)
end

puts result
