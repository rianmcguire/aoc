#!/usr/bin/env ruby

nodes = {}
Node = Struct.new(:id, :left, :right)

instr, network = ARGF.read.split("\n\n")

network.each_line do |line|
    id, rest = line.chomp.split(" = ")
    left, right = rest.scan(/\w+/)

    nodes[id] = Node.new(id, left, right)
end

current = nodes["AAA"]
i = 0
loop do
    break if current.id == "ZZZ"

    go = instr[i % instr.length]
    i += 1

    if go == "L"
        current = nodes[current.left]
    else
        current = nodes[current.right]
    end
end

puts i
