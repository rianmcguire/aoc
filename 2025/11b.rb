#!/usr/bin/env ruby

graph = {}

ARGF.each_line.map do |line|
  from, to = line.chomp.split(": ")
  to = to.split

  graph[from] = to
end

CRITICAL_NODES = Set.new(["dac", "fft"])

def dfs(source:, adjacent_fn:, target_fn:)
  stack = [[source, [source]]]
  counts = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = 0 } }

  while (node, path = stack.pop)
    seen_state = CRITICAL_NODES & path

    if target_fn.call(node)
      path.each do |n|
        seen_state = seen_state.dup.delete(n)
        counts[n][seen_state] += 1
      end
      next
    end

    if counts.key?(node)
      counts[node].each do |count_state, count|
        next unless count > 0

        combined_state = seen_state + count_state
        path[0...-1].each do |n|
          combined_state = combined_state.dup.delete(n)
          counts[n][combined_state] += count
        end
      end
      next
    end

    adjacent_fn.call(node).filter_map do |child|
      next if path.include?(child)

      new_path = path.dup
      new_path << child
      stack.push([child, new_path])
    end
  end

  counts[source][CRITICAL_NODES]
end

target = "out"
result = dfs(
  source: "svr",
  adjacent_fn: proc do |state|
    next [] if state == target
    graph.fetch(state, [])
  end,
  target_fn: proc do |state|
    state == target
  end,
)

puts result
