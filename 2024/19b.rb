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
designs = designs.each_line.map(&:chomp)

trie = Trie.new
available.each { |a| trie.add a }

TrieCursor = Struct.new(:node, :count)
designs.sum do |d|
  cursors = [TrieCursor.new(trie.root, 1)]
  d.chars.each do |c|
    terminals_found = 0
    cursors.each do |cursor|
      next if cursor.count == 0

      node = cursor.node
      if !node.walk!(c)
        # No matching towel. This path is dead.
        cursor.count = 0
      elsif node.terminal?
        # We found a valid towel - start an additional cursor at the root
        terminals_found += cursor.count
      end
    end
    cursors << TrieCursor.new(trie.root, terminals_found)
  end

  cursors.filter { _1.node.terminal? }.sum { _1.count }
end.then { puts _1 }
