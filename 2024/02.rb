#!/usr/bin/env ruby

ARGF.each_line.filter do |line|
  levels = line.split.map(&:to_i)

  all_inc = levels.sort == levels
  all_dec = levels.sort.reverse == levels

  diffs = levels.drop(1).zip(levels).map { |a,b| (a-b).abs }

  (all_inc || all_dec) && (diffs.all? { |d| d >= 1 && d <= 3 })
end.count.then { puts _1 }
