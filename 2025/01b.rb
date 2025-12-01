#!/usr/bin/env ruby

result = 0

pos = 50
ARGF.each_line do |line|
  dir = line[0]
  n = line[1..].to_i

  # TODO: lol. figure out the analytical solution
  n.times do
    if dir == "L"
      pos -= 1
    else
      pos += 1
    end

    pos = pos % 100

    result += 1 if pos == 0
  end
end

puts result
