#!/usr/bin/env ruby

ranges = ARGF.read.chomp.split(",").map { |r| Range.new(*r.split("-")) }

result = ranges.sum do |r|
  r.sum do |n|
    len = n.length
    next 0 if len % 2 != 0
    
    l = n[0...len/2]
    r = n[len/2...]
    
    if l == r
      n.to_i
    else
      0
    end
  end
end

puts result
