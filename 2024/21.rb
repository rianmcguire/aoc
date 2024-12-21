#!/usr/bin/env ruby

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
  parent = {}

  while !frontier.empty?
    current = frontier.pop

    if target_fn.call(current)
      # Return path back to start
      path = []
      while current
        path.unshift current
        current = parent[current]
      end
      return path
    end

    adjacent_fn.call(current).each do |child|
      new_cost = cost_so_far[current] + cost_fn.call(current, child)
      if !cost_so_far.include?(child) || new_cost < cost_so_far[child]
        cost_so_far[child] = new_cost
        priority = new_cost + heuristic_fn.call(child)
        parent[child] = current
        frontier.push(child, priority)
      end
    end
  end
end

DIRS = %w(^ v < >)

Pos = Struct.new(:x, :y) do
  def step(dir)
    case dir
    when "^"
      Pos.new(x, y - 1)
    when "v"
      Pos.new(x, y + 1)
    when ">"
      Pos.new(x + 1, y)
    when "<"
      Pos.new(x - 1, y)
    else
      raise "wtf"
    end
  end
end

Keypad = Struct.new(:grid) do
  def coord(key)
    @coord_memo ||= {}
    @coord_memo[key] ||= (
      grid.each_with_index do |row, y|
        row.each_with_index do |c, x|
          return Pos.new(x, y) if c == key
        end
      end

      raise "Unknown key: #{key.inspect}"
    )
  end

  def key(pos)
    return if pos.y < 0 || pos.y > grid.length - 1
    return if pos.x < 0 || pos.x > grid[0].length - 1

    grid[pos.y][pos.x]
  end

  State = Struct.new(:pos, :last_dir)

  def path(from, to, cost_fn)
    @path_memo ||= {}
    @path_memo[[from, to]] ||= (
      a_star(
        source: State.new(coord(from), "A"),
        adjacent_fn: proc do |state|
          DIRS.filter_map do |dir|
            new_pos = state.pos.step(dir)
            new_key = key(new_pos)
            next if !new_key || new_key == "."

            State.new(new_pos, dir)
          end
        end,
        target_fn: proc do |state|
          key(state.pos) == to
        end,
        cost_fn:,
        heuristic_fn: proc do |pos|
          0
        end,
      ).then { _1[1..].map(&:last_dir) }
    )
  end

  def apply(seq)
    result = []
    pos = coord("A")
    seq.chars.each do |c|
      if c == "A"
        result << key(pos)
      else
        pos = pos.step(c)
      end
    end

    result.join
  end
end

NUMERIC = Keypad.new([
  %w(7 8 9),
  %w(4 5 6),
  %w(1 2 3),
  %w(. 0 A),
])

DIRECTIONAL = Keypad.new([
  %w(. ^ A),
  %w(< v >),
])

def sequence(goal, keypad, cost_fn)
  pos = "A"
  goal.chars.flat_map do |c|
    [*keypad.path(pos, c, cost_fn), "A"].tap { pos = c }
  end.join
end

codes = ARGF.each_line(chomp: true).to_a

zero_cost = proc { |from, to| 0 }
directional_cost = proc do |from, to|
  DIRECTIONAL.path(from.last_dir, to.last_dir, zero_cost).length
end
codes[-1..].sum do |code|
  pp code
  seq = sequence(code, NUMERIC, directional_cost)
  pp seq
  # seq = "^A<<^^A>>AvvvA"
  pp seq
  seq = sequence(seq, DIRECTIONAL, directional_cost)
  pp seq
  seq = sequence(seq, DIRECTIONAL, zero_cost)
  pp seq

  pp seq.length

  code.to_i * seq.length
end.then { puts _1 }

puts "----"

pp DIRECTIONAL.apply("<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A")
pp DIRECTIONAL.apply("<A>Av<<AA>^AA>AvAA^A<vAAA>^A")
pp NUMERIC.apply("^A<<^^A>>AvvvA")

pp sequence("<A>Av<<AA>^AA>AvAA^A<vAAA>^A", DIRECTIONAL, directional_cost)
