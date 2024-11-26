#!/usr/bin/env ruby

workflow_block, parts_block = ARGF.read.split("\n\n")

Rule = Struct.new(:var, :op, :val, :target) do
    def apply(part)
        if var
            if part[var].send(op, val)
                target
            else
                nil
            end
        else
            target
        end
    end
end

workflows = {}
workflow_block.each_line do |line|
    match = line.match(/(\w+){([^}]+)}/)
    id = match[1]
    rules = match[2].split(",")

    rules = rules.map do |rule|
        match = rule.match /(\w+)([<>])(\d+):(\w+)/
        if match
            # Conditional rule
            var, op, val, target = match[1..]
            val = val.to_i
            Rule.new(var, op, val, target)
        else
            # Rule value is just the name of the next workflow to jump to
            Rule.new(nil, nil, nil, rule)
        end
    end

    workflows[id] = rules
end

Part = Struct.new(:x, :m, :a, :s) do
    def value
        x + m + a + s
    end
end

parts = []
parts_block.each_line do |line|
    parts << Part.new(*line.scan(/\d+/).map(&:to_i))
end

accepted = []
parts.each do |part|
    id = "in"
    loop do
        if id == "A"
            accepted << part
            break
        elsif id == "R"
            # Rejected
            break
        end

        workflows.fetch(id).each do |rule|
            id = rule.apply(part)
            break if id
        end
    end
end

puts accepted.sum { |part| part.value }
