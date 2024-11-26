#!/usr/bin/env ruby

FlipFlop = Struct.new(:id, :targets) do
    def initialize(...)
        super
        @state = false
    end

    def receive(pulse)
        if pulse.type == false
            @state = !@state
            targets.map do |target|
                Pulse.new(id, target, @state)
            end
        else
            # High pulses are ignored
            []
        end
    end
end

Conj = Struct.new(:id, :targets, :sources) do
    def initialize(...)
        super
        @state = Hash.new { |h,k| false }
    end

    def receive(pulse)
        @state[pulse.source] = pulse.type

        out_type = !sources.all? { @state[_1] }

        targets.map do |target|
            Pulse.new(id, target, out_type)
        end
    end
end

Broadcaster = Struct.new(:id, :targets) do
    def receive(pulse)
        targets.map do |target|
            Pulse.new(id, target, pulse.type)
        end
    end
end

Output = Struct.new(:id) do
    def receive(pulse)
        []
    end

    def targets
        []
    end
end

network = {
    "output" => Output.new("output")
}
conj_nodes = []
ARGF.each_line do |line|
    mod, targets = line.chomp.split(" -> ")
    targets = targets.split(", ")

    if mod[0] == "%"
        id = mod[1..]
        network[id] = FlipFlop.new(id, targets)
    elsif mod[0] == "&"
        id = mod[1..]
        network[id] = Conj.new(id, targets, [])
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

Pulse = Struct.new(:source, :target, :type)

counts = Hash.new { |h, k| h[k] = 0 }
1000.times do
    queue = [Pulse.new("button", "broadcaster", false)]
    while pulse = queue.shift
        counts[pulse.type] += 1
        if network.include?(pulse.target)
            queue.concat(network.fetch(pulse.target).receive(pulse))
        end
    end
end

puts counts.values.reduce(:*)
