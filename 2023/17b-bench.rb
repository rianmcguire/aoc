#!/usr/bin/env ruby

require 'bundler/inline'
require 'benchmark'

gemfile do
  source 'https://rubygems.org'
  gem 'pairing_heap', require: true
  gem 'rb_heap', require: true
  gem 'priority_queue_cxx'
  gem 'algorithms', require: true
  gem 'pqueue', require: true
end

require 'fc' # priority_queue_cxx

gems = {
    "pairing_heap (SimplePairingHeap)" => Class.new do
        def initialize
            @heap = PairingHeap::SimplePairingHeap.new
        end

        def push(state, priority)
            @heap.push(state, priority)
        end

        def pop
            @heap.pop
        end

        def empty?
            @heap.empty?
        end
    end,
    "rb_heap" => Class.new do
        def initialize
            @heap = Heap.new {|a, b| a[0] < b[0]}
        end

        def push(state, priority)
            @heap.add([priority, state])
        end

        def pop
            @heap.pop.last
        end

        def empty?
            @heap.empty?
        end
    end,
    "priority_queue_cxx" => Class.new do
        def initialize
            @heap = FastContainers::PriorityQueue.new(:min)
        end

        def push(state, priority)
            @heap.push(state, priority)
        end

        def pop
            @heap.pop
        end

        def empty?
            @heap.empty?
        end
    end,
    "algorithms (Containers::MinHeap)" => Class.new do
        def initialize
            @heap = Containers::MinHeap.new
        end

        def push(state, priority)
            @heap.push(priority, state)
        end

        def pop
            @heap.min!
        end

        def empty?
            @heap.empty?
        end
    end,
    "pqueue" => Class.new do
        def initialize
            @heap = PQueue.new do |a, b|
                b[0] <=> a[0]
            end
        end

        def push(state, priority)
            @heap.push([priority, state])
        end

        def pop
            @heap.pop.last
        end

        def empty?
            @heap.empty?
        end
    end,
}

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

MAP = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        c.to_i
    end
end

MAX_Y = MAP.length - 1
MAX_X = MAP.first.length - 1

# https://www.redblobgames.com/pathfinding/a-star/introduction.html#astar
def a_star(priority_queue_class:, source:, adjacent_fn:, target_fn:, heuristic_fn:, cost_fn:)
    frontier = priority_queue_class.new
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

def solve(priority_queue_class)
    target = Pos.new(MAX_X, MAX_Y)
    state = State.new(pos: Pos.new(0, 0), last_dir: nil, last_dir_count: 0)
    loss = a_star(
        priority_queue_class:,
        source: state,
        adjacent_fn: proc do |state|
            new_states = [:n, :s, :w, :e].filter_map do |dir|
                # Can't reverse direction
                next if reverse(dir) == state.last_dir
    
                # Can't got straight for more than 10 steps
                next if dir == state.last_dir && state.last_dir_count >= 10
    
                # Can't turn until 4 steps
                next if state.last_dir && dir != state.last_dir && state.last_dir_count < 4
    
                new_pos = state.pos.step(dir)
                next unless new_pos.valid?
    
                State.new(pos: new_pos, last_dir: dir, last_dir_count: dir == state.last_dir ? state.last_dir_count + 1 : 1)
            end
    
            new_states
        end,
        target_fn: proc do |state|
            # Must have travelled a minimum of 4 before stopping
            state.pos == target && state.last_dir_count >= 4
        end,
        heuristic_fn: proc do |state|
            state.pos.dist(target)
        end,
        cost_fn: proc do |from, to|
            MAP[to.pos.y][to.pos.x]
        end,
    )

    raise "Invalid result: #{loss}" if loss != 1178
end

Benchmark.bmbm(gems.keys.map(&:length).max) do |x|
    gems.each do |label, priority_queue_class|
        x.report(label) do
            solve(priority_queue_class)
        end
    end
end
