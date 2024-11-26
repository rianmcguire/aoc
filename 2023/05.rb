#!/usr/bin/env ruby

seeds, *maps = ARGF.read.split("\n\n")

seeds = seeds.split(": ").last.split(" ").map(&:to_i)

RangeMapping = Struct.new(:dest_start, :source_start, :length) do
    def source_range
        (source_start...(source_start+length))
    end

    # Map a source value to a destination value
    def transform(source)
        dest_start + (source - source_start)
    end
end

# Parse each map into an array of RangeMappings
maps.map! do |block|
    block.lines[1..].map do |line|
        RangeMapping.new(*line.split(" ").map(&:to_i))
    end
end

seeds.map do |seed|
    # Start with the seed value
    value = seed

    # Run the value through each of the maps in order
    maps.each do |mappings|
        mapping = mappings.find { _1.source_range.include? value }

        if mapping
            # There's a range mapping covering the source value - transform to a destination value
            value = mapping.transform(value)
        else
            # Value is unchanged
        end
    end

    value
end.min.then { puts _1 }
