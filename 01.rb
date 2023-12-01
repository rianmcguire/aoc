#!/usr/bin/env ruby

result = ARGF.each_line.map do |line|
    digits = line.scan /\d/
    "#{digits.first}#{digits.last}".to_i
end.sum

puts result

