#!/usr/bin/env ruby

words = %w(one two three four five six seven eight nine)

result = ARGF.each_line.map do |line|
    digits = line.scan(/(?=(\d|one|two|three|four|five|six|seven|eight|nine))/).flatten
    digits.map! do |d|
        if i = words.index(d)
            i + 1
        else
            d
        end
    end

    "#{digits.first}#{digits.last}".to_i
end.sum

puts result

