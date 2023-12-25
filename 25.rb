#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
    source 'https://rubygems.org'
    gem 'rgl'
end


require 'rgl/adjacency'
require 'rgl/connected_components'

g = RGL::AdjacencyGraph.new
ARGF.each_line do |line|
    head, *others = line.chomp.scan(/\w+/)
    others.each do |o|
        g.add_edge(head, o)
    end
end

# lol graphviz
g.remove_edge("fmr", "zhg")
g.remove_edge("krf", "crg")
g.remove_edge("rgv", "jct")

sizes = []
g.each_connected_component do |comp|
    sizes << comp.size
end

pp sizes.reduce(:*)

# pp g

# # https://en.wikipedia.org/wiki/Karger%27s_algorithm
# def contract(g)
#     g = g.dup
#     while g.vertices.length > 2
#         e = g.edges.sample

#         vertices = [e.source, e.target].flat_map { |v| g.adjacent_vertices(v) }.uniq - [e.source, e.target]

#         g.remove_vertex(e.source)
#         g.remove_vertex(e.target)

#         vertices.each do |v|
#             g.add_edge("#{e.source}+#{e.target}", v)
#         end
#     end
#     g
# end

# pp contract(g)

# fmr--zhg
# krf--crg
# rgv--jct

