#!/usr/bin/env ruby

FlipFlop = Struct.new(:id, :targets, :state) do
    def name
        "%#{id}"
    end

    def receive(pulse)
        if pulse.type == false
            self.state = !state
            targets.map do |target|
                Pulse.new(id, target, state)
            end
        else
            # High pulses are ignored
            []
        end
    end
end

Conj = Struct.new(:id, :targets, :sources, :state) do
    def name
        "&#{id}"
    end

    def receive(pulse)
        state[pulse.source] = pulse.type

        out_type = !sources.all? { state[_1] }

        targets.map do |target|
            Pulse.new(id, target, out_type)
        end
    end

    def sources=(value)
        self[:sources] = value
        value.each { state[_1]  = false }
    end
end

Broadcaster = Struct.new(:id, :targets) do
    def name
        id
    end

    def receive(pulse)
        targets.map do |target|
            Pulse.new(id, target, pulse.type)
        end
    end

    def state
        nil
    end
end

Output = Struct.new(:id) do
    def name
        id
    end

    def receive(pulse)
        []
    end

    def targets
        []
    end

    def state
        nil
    end
end

network = {
    "rx" => Output.new("rx")
}
conj_nodes = []
ARGF.each_line do |line|
    mod, targets = line.chomp.split(" -> ")
    targets = targets.split(", ")

    if mod[0] == "%"
        id = mod[1..]
        network[id] = FlipFlop.new(id, targets, false)
    elsif mod[0] == "&"
        id = mod[1..]
        network[id] = Conj.new(id, targets, [], {})
        conj_nodes << network[id]
    elsif mod == "broadcaster"
        id = mod
        network[id] = Broadcaster.new(id, targets)
    else
        raise "Unknown: #{line}"
    end
end

# Get sources for Conj nodes
conj_nodes.each do |conj|
    conj.sources = network.values.filter { |n| n.targets.include?(conj.id) }.map(&:id)
end

# Output a DOT file for the graph for manual inspection
# Generate an SVG with: dot -Tsvg 20.dot -o 20.svg

# puts "digraph graphname {"
# network.each do |id, node|
#     node.targets.each do |target|
#         puts "\"#{node.name}\" -> \"#{network[target].name}\";"
#     end
# end
# puts "}"

Pulse = Struct.new(:source, :target, :type)

rx_parents = network.values.filter { |n| n.targets.include?("rx") }
raise "This solution won't work" if rx_parents.length != 1
rx_parent = rx_parents.first
raise "This solution won't work" unless rx_parent.is_a?(Conj)

parent_pulses = {}
catch :done do
    n = 0
    loop do
        n += 1
        queue = [Pulse.new("button", "broadcaster", false)]
        while pulse = queue.shift
            # Track when rx_parent receives a high pulse from each of its sources
            if pulse.target == rx_parent.id && pulse.type == true
                # We're done when we've seen all the sources
                throw :done if parent_pulses.keys.length == rx_parent.sources.length
                parent_pulses[pulse.source] = n
            end

            queue.concat(network.fetch(pulse.target).receive(pulse))
        end
    end
end

# The pulses are periodic, so rx_parent will emit a low pulse when all its sources emit a high pulse at the same time.
puts parent_pulses.values.reduce(:*)
