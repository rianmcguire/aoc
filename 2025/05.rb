#!/usr/bin/env ruby

ranges, avail = ARGF.read.split("\n\n")

ranges = ranges.each_line.map do |line|
  Range.new(*line.chomp.split("-").map(&:to_i))
end

avail = avail.each_line.map { |l| l.chomp.to_i }

result = avail.count do |a|
  ranges.any? { it.include? a }
end
puts result
