#!/usr/bin/env ruby

ranges = ARGF.read.chomp.split(",").map { |r| Range.new(*r.split("-")) }

result = ranges.sum do |r|
  r.sum do |n|
    len = n.length
    
    invalid = (1..len/2).any? do |seq_len|
      next unless len % seq_len == 0

      seq = n[0...seq_len]
      n == seq * (len / seq_len)
    end
    
    if invalid
      n.to_i
    else
      0
    end
  end
end

puts result
