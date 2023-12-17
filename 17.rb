#!/usr/bin/env ruby

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
        (0..MAX).include?(x) && (0..MAX).include?(y)
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

MAX = map.length - 1

def cost(node)
    $map[node.pos.y][node.pos.x]
end

def bfs(source:, adjacent_fn:, target_fn:)
    to_explore = [source]
    explored = Set.new([source])
    path = {}
    path[source] = []

    dist = Hash.new { |h, k| h[k] = 99999999 }
    dist[source] = 0

    while to_explore.any?
        to_explore.sort_by! { dist[_1] }
        node = to_explore.shift
        puts "#{to_explore.count} #{dist[node]}"

        if target_fn.call(node)
            return path[node], dist[node]
        end

        adjacent_fn.call(node).each do |child|
            if explored.include?(child)
                next
            elsif dist[child] > dist[node] + cost(child)
                if !to_explore.include?(child)
                    to_explore << child
                end
                dist[child] = dist[node] + cost(child)
                path[child] = path[node]
                path[child] << child
            end
        end
    end

    nil
end

State = Struct.new(:pos, :last_dir, :last_dir_count)

state = State.new(pos: Pos.new(0, 0), last_dir: nil, last_dir_count: 0) 
path, loss = bfs(
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
        state.pos.x == MAX && state.pos.y == MAX
    end,
)

pp loss