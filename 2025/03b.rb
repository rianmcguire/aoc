#!/usr/bin/env ruby

def solve(cs, n, memo = {})
  memo[[cs, n]] ||= (
    return cs.chars.max if n == 1

    opts = cs[0...-(n - 1)]
    max = opts.chars.max

    opts.chars.each_with_index.filter { |c, i| c == max }.map do |c, i|
      "#{c}#{solve(cs[i+1...], n-1, memo)}"
    end.max
  )
end

result = ARGF.each_line.sum do |line|
  solve(line.chomp, 12).to_i
end

puts result
