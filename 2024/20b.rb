#!/usr/bin/env ruby

DIRS = [:n, :e, :s, :w]

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

  def valid?
    X_RANGE.include?(x) && Y_RANGE.include?(y) && GRID[y][x] != "#"
  end

  def +(b)
    Pos.new(x + b.x, y + b.y)
  end

  def dist(b)
    a = self
    (a.x - b.x).abs + (a.y - b.y).abs
  end
end

start_pos = end_pos = nil
GRID = ARGF.each_line.with_index.map do |row, y|
  row.chomp.chars.each_with_index.map do |c, x|
    case c
    when "S"
      start_pos = Pos.new(x,y)
      c = "."
    when "E"
      end_pos = Pos.new(x, y)
      c = "."
    end
    c
  end
end

Y_RANGE = (0..GRID.length - 1)
X_RANGE = (0..GRID.first.length - 1)

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
      # Return the distances
      return cost_so_far
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

distances = a_star(
  source: end_pos,
  adjacent_fn: proc do |pos|
    DIRS.map { |dir| pos.step(dir) }.filter { |pos| pos.valid? }
  end,
  target_fn: proc do |pos|
    pos == start_pos
  end,
  heuristic_fn: proc do |pos|
    # BFS
    0
  end,
  cost_fn: proc do |from, to|
    # BFS
    1
  end,
)

cheat_length = 20
cheats = []
distances.each do |cheat_start, original_dist|
  (-cheat_length..cheat_length).each do |y_off|
    (-cheat_length..cheat_length).each do |x_off|
      cheat_end = cheat_start + Pos.new(x_off, y_off)
      next unless distances.include?(cheat_end)
      dist = cheat_start.dist(cheat_end)
      next unless dist <= cheat_length

      saving = original_dist - distances.fetch(cheat_end) - dist

      cheats << saving if saving >= 100
    end
  end
end

puts cheats.length
