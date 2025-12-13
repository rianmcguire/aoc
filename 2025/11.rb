#!/usr/bin/env ruby

graph = {}

ARGF.each_line.map do |line|
  from, to = line.chomp.split(": ")
  to = to.split

  graph[from] = to
end

def dfs(source:, adjacent_fn:, target_fn:)
  stack = [[source, [source]]]
  paths = []

  while (node, path = stack.pop)
    if target_fn.call(node)
      paths << path
    end

    adjacent_fn.call(node).filter_map do |child|
      new_path = path.dup
      new_path << child
      stack.push([child, new_path])
    end
  end

  paths
end

puts dfs(
  source: "you",
  adjacent_fn: proc do |state|
    graph.fetch(state, [])
  end,
  target_fn: proc do |state|
    state == "out"
  end,
).length
