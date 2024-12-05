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

require 'tsort'

class Deps < Hash
  include TSort

  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

def reorder(update)
  rules_for_update = RULES.filter { |a,b|  update.include?(a) && update.include?(b) }

  deps = Deps.new { |h,k| h[k] = [] }
  update.each do |n|
    deps[n] = []
  end
  rules_for_update.each do |before,after|
    deps[after] << before
  end

  deps.tsort
end

result = 0
updates.each do |update|
  if !correct?(update)
    fixed = reorder(update)
    raise "wtf" unless correct?(fixed)
    result += fixed[fixed.length / 2].to_i
  end
end
puts result
