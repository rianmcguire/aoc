#!/usr/bin/env ruby

result = ARGF.each_line.sum do |line|
  cs = line.chomp.chars
  a, ai = cs[0...-1].each_with_index.max_by { |c, _| c }
  b = cs[ai+1..].max
  "#{a}#{b}".to_i
end

puts result
