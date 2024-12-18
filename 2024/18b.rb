#!/usr/bin/env ruby

DIRS = [:n, :s, :w, :e]

Pos = Struct.new(:x, :y) do
  def step(dir)
    case dir
    when :n
      Pos.new(x, y - 1)
    when :s
      Pos.new(x, y + 1)
    when :e
      Pos.new(x + 1, y)
    when :w
      Pos.new(x - 1, y)
    else
      raise "wtf"
    end
  end

  def neighbours
    DIRS.map { step(_1) }.filter(&:valid?)
  end

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y)
  end
end

all_bytes = ARGF.each_line.map { Pos.new(*_1.scan(/\d+/).map(&:to_i)) }

Y_RANGE = 0..all_bytes.map(&:y).max
X_RANGE = 0..all_bytes.map(&:x).max

start = Pos.new(0, 0)

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'pairing_heap', '3.0.1', require: true
end
# https://www.redblobgames.com/pathfinding/a-star/introduction.html#astar
def a_star(source:, adjacent_fn:, target_fn:, heuristic_fn:, cost_fn:)
  frontier = PairingHeap::SimplePairingHeap.new
  frontier.push(source, 0)

  cost_so_far = {}
  cost_so_far[source] = 0

  while !frontier.empty?
    current = frontier.pop

    if target_fn.call(current)
      return cost_so_far[current]
    end

    adjacent_fn.call(current).each do |child|
      new_cost = cost_so_far[current] + cost_fn.call(current, child)
      if !cost_so_far.include?(child) || new_cost < cost_so_far[child]
        cost_so_far[child] = new_cost
        priority = new_cost + heuristic_fn.call(child)
        frontier.push(child, priority)
      end
    end
  end
end

end_pos = Pos.new(X_RANGE.max, Y_RANGE.max)

# TODO: find the non-brute-force solution
(0..all_bytes.length).each do |i|
  bytes = all_bytes.first(i).to_set
  found = a_star(
    source: start,
    adjacent_fn: proc do |pos|
      pos.neighbours.filter { !bytes.include?(_1) }
    end,
    target_fn: proc do |pos|
      pos == end_pos
    end,
    heuristic_fn: proc do |pos|
      # We're just doing BFS
      0
    end,
    cost_fn: proc do |from, to|
      # We're just doing BFS
      1
    end,
  )

  if !found
    puts all_bytes[i - 1].to_a.join(",")
    break
  end
end
