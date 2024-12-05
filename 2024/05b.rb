#!/usr/bin/env ruby

require "tsort"
require "set"

class Deps < Hash
  include TSort

  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

rules, updates = ARGF.read.split("\n\n")

RULES = rules.each_line.map { _1.chomp.split("|") }
updates = updates.each_line.map { _1.chomp.split(",") }

def reorder(update)
  update_set = Set.new(update)
  rules_for_update = RULES.filter { |a, b| update_set.include?(a) && update_set.include?(b) }

  deps = Deps.new
  update.each do |n|
    deps[n] = []
  end
  rules_for_update.each do |before, after|
    deps[after] << before
  end

  deps.tsort
end

result = 0
updates.each do |update|
  fixed = reorder(update)
  if fixed != update
    # If the order changed, it was incorrectly ordered
    result += fixed[fixed.length / 2].to_i
  end
end
puts result
