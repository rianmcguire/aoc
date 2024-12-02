#!/usr/bin/env ruby

def safe?(levels)
  all_inc = levels.sort == levels
  all_dec = levels.sort.reverse == levels
  diffs = levels.drop(1).zip(levels)
    .map { |a,b| (a-b).abs }
    .all? { |d| (1..3).include?(d) }

  (all_inc || all_dec) && diffs
end

def try_removals(levels)
  (0...levels.length).each do |i|
    modified = levels.dup
    modified.delete_at(i)
    return true if safe?(modified)
  end
  false
end

ARGF.each_line.filter do |line|
  levels = line.split.map(&:to_i)

  safe?(levels) || try_removals(levels)
end.count.then { puts _1 }
