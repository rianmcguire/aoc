#!/usr/bin/env ruby

DIGITS = %w(zero one two three four five six seven eight nine)

result = ARGF.each_line.map do |line|
    # Use postive lookahead so we match both "five" and "eight" in a string like "fiveight" instead of
    # just "five" -- "eight" is considered the last digit.
    digits = line.scan(/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/).flatten
    digits.map! do |d|
        DIGITS.index(d) || d
    end

    "#{digits.first}#{digits.last}".to_i
end.sum

puts result
