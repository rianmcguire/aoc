#!/usr/bin/env ruby

require 'bundler/inline'

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
        end
    end

    def valid?
        (0..MAX_X).include?(x) && (0..MAX_Y).include?(y)
    end

    def dist(b)
        a = self
        (a.x - b.x).abs + (a.y - b.y).abs
    end
end

def reverse(dir)
    case dir
    when :n
        :s
    when :s
        :n
    when :e
        :w
    when :w
        :e
    end
end

map = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        c.to_i
    end
end

MAX_Y = map.length - 1
MAX_X = map.first.length - 1

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

State = Struct.new(:pos, :last_dir, :last_dir_count)

target = Pos.new(MAX_X, MAX_Y)
state = State.new(pos: Pos.new(0, 0), last_dir: nil, last_dir_count: 0)
loss = a_star(
    source: state,
    adjacent_fn: proc do |state|
        new_states = [:n, :s, :w, :e].filter_map do |dir|
            # Can't reverse direction
            next if reverse(dir) == state.last_dir

            # Can't got straight for more than 3 steps
            next if dir == state.last_dir && state.last_dir_count == 3

            new_pos = state.pos.step(dir)
            next unless new_pos.valid?

            State.new(pos: new_pos, last_dir: dir, last_dir_count: dir == state.last_dir ? state.last_dir_count + 1 : 1)
        end

        new_states
    end,
    target_fn: proc do |state|
        state.pos == target
    end,
    heuristic_fn: proc do |state|
        state.pos.dist(target)
    end,
    cost_fn: proc do |from, to|
        map[to.pos.y][to.pos.x]
    end,
)

pp loss
