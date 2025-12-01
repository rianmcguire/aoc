#!/usr/bin/env ruby

result = 0

pos = 50
ARGF.each_line do |line|
  dir = line[0]
  n = line[1..].to_i

  if dir == "L"
    n = -n
  end

  pos = (pos + n) % 100

  if pos == 0
    result += 1
  end
end

puts result
