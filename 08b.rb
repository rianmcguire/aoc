#!/usr/bin/env ruby

nodes = {}
Node = Struct.new(:id, :left, :right)

instr, network = ARGF.read.split("\n\n")

network.each_line do |line|
    id, rest = line.chomp.split(" = ")
    left, right = rest.scan(/\w+/)

    nodes[id] = Node.new(id, left, right)
end

currents = nodes.values.filter {  _1.id.end_with?("A") }
periods = Array.new(currents.length, nil)
i = 0
loop do
    currents.each_with_index do |current, index|
        if current.id.end_with?("Z")
            periods[index] = i
        end
    end

    break if periods.all?

    instr.chars.each do |go|
        if go == "L"
            currents = currents.map { nodes[_1.left] }
        else
            currents = currents.map { nodes[_1.right] }
        end
    end
    i += instr.length
end

puts periods.reduce(:lcm)
