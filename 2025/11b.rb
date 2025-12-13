#!/usr/bin/env ruby

graph = {}

ARGF.each_line.map do |line|
  from, to = line.chomp.split(": ")
  to = to.split

  graph[from] = to
end

def dfs(source:, adjacent_fn:, target_fn:, critical_nodes:)
  stack = [[source, [source]]]

  # Hash[node, Hash[set of critical nodes on the paths to the target from node, count of paths]]
  counts = Hash.new { |h,k| h[k] = Hash.new { |hh,kk| hh[kk] = 0 } }

  while (node, path = stack.pop)
    seen_state = critical_nodes & path

    if target_fn.call(node)
      path.each do |n|
        seen_state = seen_state - [n]
        counts[n][seen_state] += 1
      end
      next
    end

    if counts.key?(node)
      # We've found a path to the target from this node before.
      # Propogate the counts back along our path.
      counts[node].each do |count_state, count|
        combined_state = seen_state + count_state
        path[0...-1].each do |n|
          combined_state = combined_state - [n]
          counts[n][combined_state] += count
        end
      end
      next
    end

    adjacent_fn.call(node).filter_map do |child|
      new_path = path.dup
      new_path << child
      stack.push([child, new_path])
    end
  end

  counts[source][critical_nodes]
end

result = dfs(
  source: "svr",
  adjacent_fn: proc do |state|
    graph.fetch(state, [])
  end,
  target_fn: proc do |state|
    state == "out"
  end,
  critical_nodes: Set.new(["dac", "fft"]),
)

puts result
