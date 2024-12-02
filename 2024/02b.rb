#!/usr/bin/env ruby

def safe?(levels)
  all_inc = levels.sort == levels
  all_dec = levels.sort.reverse == levels

  diffs = levels.drop(1).zip(levels).map { |a,b| (a-b).abs }

  (all_inc || all_dec) && (diffs.all? { |d| d >= 1 && d <= 3 })
end

ARGF.each_line.filter do |line|
  levels = line.split.map(&:to_i)

  if !safe?(levels)
    found_safe = false
    (0..levels.length).each do |i|
      modified = levels.dup
      modified.delete_at(i)

      if safe?(modified)
        found_safe = true
        break
      end
    end

    found_safe
  else
    true
  end
end.count.then { puts _1 }
