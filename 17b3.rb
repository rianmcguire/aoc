#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'pqueue', require: true
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

$map = map = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        c.to_i
    end
end

MAX_Y = map.length - 1
MAX_X = map.first.length - 1

def astar(source:, adjacent_fn:, target_fn:, heuristic_fn:, weight_fn:)
    open_set = PQueue.new

    g_score = Hash.new { |h, k| h[k] = 99999999 }
    g_score[source] = 0

    f_score = Hash.new { |h, k| h[k] = 99999999 }
    f_score[source] = heuristic_fn.call(source)

    open_set.push([f_score[source], source])

    while !open_set.empty?
        # open_set.sort_by! { f_score[_1] }
        _, current = open_set.shift

        if target_fn.call(current)
            return g_score[current]
        end

        adjacent_fn.call(current).each do |child|
            tentative_score = g_score[current] + weight_fn.call(child)
            if tentative_score < g_score[child]
                g_score[child] = tentative_score
                f_score[child] = tentative_score + heuristic_fn.call(child)
                # if !open_set.include?(child)
                    open_set.push([f_score[child], child])
                # end
            end
        end
    end
end

State = Struct.new(:pos, :last_dir, :last_dir_count, :f_score)

target = Pos.new(MAX_X, MAX_Y)

FSCORE_MAX = 999999

state = State.new(pos: Pos.new(0, 0), last_dir: nil, last_dir_count: 0, f_score: FSCORE_MAX) 
loss = astar(
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
    weight_fn: proc do |state|
        $map[state.pos.y][state.pos.x]
    end,
)

pp loss
