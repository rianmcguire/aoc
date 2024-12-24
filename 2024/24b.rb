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

GATE_VALUES = {}

DEPS = Deps.new
initial.each_line(chomp: true).each do |l|
  gate, value = l.split(": ")
  value = value.to_i

  DEPS[gate] = []
  GATE_VALUES[gate] = value
end

gates.each_line(chomp: true).each do |l|
  a, op, b, _, out = l.split(" ")

  DEPS[out] = [a,b]

  GATE_VALUES[out] = [op, a, b]
end

OPS = {
  "XOR" => :^,
  "OR" => :|,
  "AND" => :&,
}

def run(gate_values, deps)
  gate_values = gate_values.dup

  deps.tsort.each do |gate|
    next if gate_values[gate].is_a?(Integer)

    op, a, b = gate_values[gate]
    op = OPS[op]
    a = gate_values[a]
    b = gate_values[b]

    gate_values[gate] = a.send(op, b)
  end

  gate_values
end

def result(prefix, gate_values)
  gate_values.keys
    .filter { _1[0] == prefix }
    .sort.reverse
    .reduce(0) { |memo, gate| (memo << 1) | gate_values[gate] }
end

def set_gates(prefix, gate_values, n)
  n_gates = gate_values.keys.count { _1[0] == prefix }

  result = []
  mask = 1
  n_gates.times do |i|
    result << "#{prefix}#{sprintf('%02d', i)}" if n.anybits?(mask)
    mask <<= 1
  end
  result
end

gate_values = run(GATE_VALUES, DEPS)
x = result("x", gate_values)
y = result("y", gate_values)
expected = x & y
actual = result("z", gate_values)

diff = expected ^ actual
bad_gates = set_gates("z", gate_values, diff)

def upstreams(gate)
  [gate, *DEPS[gate].flat_map { upstreams(_1) }]
end

def swap(hash, a, b)
  temp = hash[a]
  hash[a] = hash[b]
  hash[b] = temp
  nil
end

all_in_path = bad_gates.flat_map { |g| upstreams(g) }
all_in_path.reject! { |g| g[0] == "x" || g[0] == "y" }
pairs = all_in_path.combination(2).to_a
pp pairs
pairs.combination(2).each do |pairs|
  gate_values = GATE_VALUES.dup
  deps = DEPS.dup

  # Try swapping all of the pairs
  pairs.each do |a, b|
    swap(gate_values, a, b)
    swap(deps, a, b)
  end

  pp deps

  gate_values = run(gate_values, deps)
  if result("z", gate_values) == expected
    pp "got it"
    pp pairs
    break
  end
end
