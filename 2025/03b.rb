#!/usr/bin/env ruby

def solve(bank, n, memo = {})
  memo[[bank, n]] ||= (
    return "" if n == 0

    # All options for the next character to select.
    # Anything past -n isn't possible, because we'll run out of characters.
    prefix = bank[0..-n]

    # Find the largest
    max, i = prefix.chars.each_with_index.max_by { |c, i| c }

    max + solve(bank[i+1...], n-1, memo)
  )
end

result = ARGF.each_line.sum do |line|
  solve(line.chomp, 12).to_i
end

puts result
