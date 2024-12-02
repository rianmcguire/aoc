#!/usr/bin/env ruby

def safe?(levels)
  diffs = levels.drop(1).zip(levels).map { |a,b| a-b }

  all_inc = diffs.all? { _1 > 0 }
  all_dec = diffs.all? { _1 < 0 }
  range = diffs.all? { (1..3).include?(_1.abs) }

  (all_inc || all_dec) && range
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
