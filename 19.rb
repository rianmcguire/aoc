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
            var, op, val, target = match[1..]
            val = val.to_i
            Rule.new(var, op, val, target)
        else
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
    w = workflows.fetch("in")
    loop do
        new_id = nil
        w.each do |rule|
            new_id = rule.apply(part)
            break if new_id
        end

        if new_id == "A"
            accepted << part
            break
        elsif new_id == "R"
            # Rejected
            break
        end
        
        w = workflows.fetch(new_id)
    end
end

pp accepted.sum { |part| part.value }
