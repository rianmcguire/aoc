#!/usr/bin/env ruby

def solve(bank, n, memo = {})
  memo[[bank, n]] ||= (
    return "" if n == 0

    # All options for the next character to select.
    prefix = if n > 1
      # Anything past -(n-1) isn't possible, because we'll run out of characters.
      bank[0...-(n - 1)]
    else
      bank
    end

    # Search every max-valued possibility
    max = prefix.chars.max
    rest = prefix.chars.each_with_index.filter { |c, i| c == max }.map do |c, i|
      solve(bank[i+1...], n-1, memo)
    end.max

    max + rest
  )
end

result = ARGF.each_line.sum do |line|
  solve(line.chomp, 12).to_i
end

puts result
