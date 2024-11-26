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

# Start a "ghost" at all nodes that end with "A"
currents = network.values.filter {  _1.id.end_with?("A") }
periods = Array.new(currents.length, nil)
i = 0
loop do
    # If we reach a "Z", note how long it took to get there.
    #
    # After exploring the input data: one sigificant feature that we can exploit is the the number of cycles for a
    # "ghost" get to a "Z" for the first time is the same number of cycles to loop back to the same "Z" from then on.
    currents.each_with_index do |current, index|
        if current.id.end_with?("Z")
            periods[index] = i
        end
    end

    # We've found all the periods for all the ghosts
    break if periods.all?

    # We can apply entire instruction set in one go, as the positions don't cycle within it
    instr.chars.each do |dir|
        currents = currents.map { network[_1.step(dir)] }
    end
    i += instr.length
end

# Find the least common multiple of all the periods - this is the first time all the ghosts will simulaneously be on
# a "Z"
puts periods.reduce(:lcm)
