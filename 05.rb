#!/usr/bin/env ruby

seeds, *maps = ARGF.read.split("\n\n")

seeds = seeds.split(": ").last.split(" ").map(&:to_i)

RangeMapping = Struct.new(:dest_start, :source_start, :length) do
    def dest_range
        (dest_start...(dest_start+length))
    end

    def source_range
        (source_start...(source_start+length))
    end

    def map(source)
        dest_start + (source - source_start)
    end
end

maps.map! do |block|
    block.lines[1..].map do |line|
        RangeMapping.new(*line.split(" ").map(&:to_i))
    end
end

seeds.map do |seed|
    value = seed
    maps.each do |mappings|
        mapping = mappings.find { _1.source_range.include? value}

        if mapping
            value = mapping.map(value)
        else
            # Value is unchanged
        end
    end

    value
end.min.then { puts _1 }
