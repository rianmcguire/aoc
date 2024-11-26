#!/usr/bin/env ruby

instr, network_string = ARGF.read.split("\n\n")

Node = Struct.new(:id, :left, :right) do
    def step(dir)
        if dir == "L"
            left
        else
            right
        end
    end
end

# Parse the network into a hash of nodes by id
network = {}
network_string.each_line do |line|
    node = Node.new(*line.scan(/\w+/))

    network[node.id] = node
end

# Start at AAA
current = network["AAA"]
i = 0
loop do
    # We're finished when we reach ZZZ
    break if current.id == "ZZZ"

    # Get the next instruction
    dir = instr[i % instr.length]
    i += 1

    current = network[current.step(dir)]
end

puts i
