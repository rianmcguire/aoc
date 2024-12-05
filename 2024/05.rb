#!/usr/bin/env ruby

rules, updates = ARGF.read.split("\n\n")

RULES = rules.each_line.map { _1.chomp.split("|") }
updates = updates.each_line.map { _1.chomp.split(",") }

def correct?(update)
  rules_for_update = RULES.filter { |a,b| update.include?(a) && update.include?(b) }

  update.each do |n|
    rules_for_n = rules_for_update.filter { |r| r.include?(n) }
    rules_for_n.each do |before, after|
      return false if update.index(before) > update.index(after)
    end
  end

  true
end

result = 0
updates.each do |update|
  if correct?(update)
    result += update[update.length / 2].to_i
  end
end
puts result
