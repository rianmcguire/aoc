#!/usr/bin/env ruby

require 'multi_range'

workflow_block = ARGF.read.split("\n\n").first

Rule = Struct.new(:var, :op, :val, :target) do
    def invert
        raise "wtf" if !var

        if op == ">"
            Rule.new(var, "<", val + 1, target)
        elsif op == "<"
            Rule.new(var, ">", val - 1, target)
        else
            raise "wtf: #{inspect}"
        end
    end

    def range
        if op == ">"
            MultiRange.new([(val+1..4000)])
        elsif op == "<"
            MultiRange.new([(1..val-1)])
        else
            raise "wtf"
        end
    end
end

WORKFLOWS = workflows = {}
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

# Yield all possible paths that lead to "A" states
def all_paths(id, path=[], &block)
    if id == "A"
        yield path
        return
    end

    return if id == "R"

    acc = []
    WORKFLOWS[id].each do |rule|
        if rule.var
            # Rule is conditional - include it in the path and go deeper
            all_paths(rule.target, [*path, *acc, rule], &block)

            # Accumulate the inverse of this rule, so that any rules listed after this one also need to _not_ match this rule.
            acc << rule.invert
        else
            # Rule is unconditional - we don't need to include it in the path
            all_paths(rule.target, [*path, *acc], &block)
            break
        end
    end
end

paths = []
all_paths("in") do |path|
    paths << path
end

def ranges(path)
    ranges = {
        "x" => MultiRange.new([(1..4000)]),
        "m" => MultiRange.new([(1..4000)]),
        "a" => MultiRange.new([(1..4000)]),
        "s" => MultiRange.new([(1..4000)]),
    }

    # Intersect each rule on this path with the starting ranges
    path.each do |rule|
        ranges[rule.var] &= rule.range
    end

    ranges
end

def combinations(ranges)
    ranges.values.map(&:size).reduce(:*)
end

paths.sum do |path|
    combinations(ranges(path))
end.then { puts _1 }
