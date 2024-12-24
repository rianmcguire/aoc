#!/usr/bin/env ruby

require 'tsort'

initial, gates = ARGF.read.split("\n\n")

class Deps < Hash
  include TSort

  alias tsort_each_node each_key
  def tsort_each_child(node, &block)
    fetch(node).each(&block)
  end
end

gate_values = {}

deps = Deps.new
initial.each_line(chomp: true).each do |l|
  gate, value = l.split(": ")
  value = value.to_i

  deps[gate] = []
  gate_values[gate] = value
end

gates.each_line(chomp: true).each do |l|
  a, op, b, _, out = l.split(" ")

  deps[out] = [a,b]

  gate_values[out] = [op, a, b]
end

OPS = {
  "XOR" => :^,
  "OR" => :|,
  "AND" => :&,
}

deps.tsort.each do |gate|
  next if gate_values[gate].is_a?(Integer)

  op, a, b = gate_values[gate]
  op = OPS[op]
  a = gate_values[a]
  b = gate_values[b]

  gate_values[gate] = a.send(op, b)
end

z_values = gate_values.keys.filter { _1[0] == "z" }.sort.reverse.map { gate_values[_1] }

puts z_values.reduce(0) { |memo,n| (memo << 1) | n }
