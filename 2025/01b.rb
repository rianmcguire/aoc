#!/usr/bin/env ruby

result = 0

pos = 50
ARGF.each_line do |line|
  dir = line[0]
  n = line[1..].to_i

  full_rotations = n / 100
  result += full_rotations

  n %= 100

  if dir == "L"
    n = -n
  end
  
  new_pos = pos + n
  if pos != 0 && (new_pos <= 0 || new_pos >= 100)
    result += 1
  end

  pos = new_pos % 100
end

puts result
