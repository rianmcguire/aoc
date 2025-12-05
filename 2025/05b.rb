#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'multi_range', '2.2.1', require: true
end

ranges, avail = ARGF.read.split("\n\n")

ranges = ranges.each_line.map do |line|
  Range.new(*line.chomp.split("-").map(&:to_i))
end

mr = MultiRange.new([])
ranges.each do |r|
  mr |= r
end
puts mr.size
