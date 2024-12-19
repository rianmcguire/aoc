#!/usr/bin/env ruby

require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  # gem install fast_trie -v '0.5.1' -- --with-cflags=-Wno-implicit-function-declaration
  gem 'fast_trie'
end

require 'trie'

available, designs = ARGF.read.split("\n\n")
available = available.chomp.split(", ")

trie = Trie.new
available.each { |a| trie.add a }

designs = designs.each_line.map(&:chomp)

def bfs(source:, adjacent_fn:, target_fn:)
  to_explore = [source]
  explored = Set.new([source])
  parent = {}

  while to_explore.any?
    node = to_explore.shift

    if target_fn.call(node)
      return true
    end

    adjacent_fn.call(node).each do |child|
      if explored.add?(child)
        parent[child] = node
        to_explore << child
      end
    end
  end

  false
end

def possible_towels(trie, d)
  # pp "running", d.join
  d = d.dup
  result = []

  node = trie.root
  loop do
    break if d.empty?
    node = node.walk(d.shift)

    break if node.nil?

    if node.terminal?
      # This is a possibility, but there could also be a deeper match
      result << node.full_state
    end
  end

  result
end

designs.filter do |d|
  bfs(
    source: d.chars,
    adjacent_fn: proc do |d|
      possible_towels(trie, d).map { |t| d[t.length..] }
    end,
    target_fn: proc do |node|
      node.empty?
    end
  )
end.count.then { puts _1 }
