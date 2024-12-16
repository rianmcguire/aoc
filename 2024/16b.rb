#!/usr/bin/env ruby

DIRS = [:n, :e, :s, :w]

def turn(dir, n)
  DIRS[(DIRS.index(dir) + n) % DIRS.length]
end

def reverse(dir)
  turn(dir, 2)
end

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
    GRID[y][x] != "#"
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
  parents = Hash.new { |h,k| h[k] = Set.new }

  while !frontier.empty?
    current = frontier.pop

    if target_fn.call(current)
      return {parents:, cost_so_far:, current:}
    end

    adjacent_fn.call(current).each do |child|
      new_cost = cost_so_far[current] + cost_fn.call(current, child)
      # Modified so we explore equal-cost children too
      if !cost_so_far.include?(child) || new_cost <= cost_so_far[child]
        cost_so_far[child] = new_cost
        priority = new_cost + heuristic_fn.call(child)
        frontier.push(child, priority)
        parents[child] << current
      end
    end
  end
end

State = Struct.new(:pos, :dir)

state = State.new(pos: start_pos, dir: :e)
a_star(
  source: state,
  adjacent_fn: proc do |state|
    new_states = [turn(state.dir, 1), turn(state.dir, -1)].map do |dir|
      State.new(pos: state.pos, dir:)
    end

    step_pos = state.pos.step(state.dir)
    new_states << State.new(pos: step_pos, dir: state.dir) if step_pos.valid?

    new_states
  end,
  target_fn: proc do |state|
    state.pos == end_pos
  end,
  heuristic_fn: proc do |state|
    # We could do a distance heuristic, but it doesn't make a difference to the performance.
    # Without a heuristic, A* becomes Dijkstra
    0
  end,
  cost_fn: proc do |from, to|
    if from.pos != to.pos
      1
    elsif from.dir != to.dir
      1000
    else
      raise "wtf"
    end
  end,
) => {parents:, cost_so_far:, current:}

# Take the state information from the search, and find all the positions along all the equally-shortest paths
$result = Set.new
def find_shortest_path_positions(parents, cost_so_far, state)
  $result << state.pos

  parents[state].each do |parent|
    optimal_to_parent = cost_so_far[parent]

    reverse_adjacent_fn(state).each do |adjacent|
      if cost_so_far[adjacent] == optimal_to_parent
        find_shortest_path_positions(parents, cost_so_far, adjacent)
      end
    end
  end
end

# This is same as the adjacent definition above, but it steps backwards
def reverse_adjacent_fn(state)
  new_states = [turn(state.dir, 1), turn(state.dir, -1)].map do |dir|
    State.new(pos: state.pos, dir:)
  end

  step_pos = state.pos.step(reverse(state.dir))
  new_states << State.new(pos: step_pos, dir: state.dir) if step_pos.valid?

  new_states
end

find_shortest_path_positions(parents, cost_so_far, current)
puts $result.length
