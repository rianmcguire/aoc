#!/usr/bin/env ruby

require 'multi_range'

seeds, *maps = ARGF.read.split("\n\n")

seeds = seeds.split(": ").last.split(" ").map(&:to_i).each_slice(2).to_a

RangeMapping = Struct.new(:dest_start, :source_start, :length) do
    def source_range
        (source_start..(source_start+length-1))
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

seeds.map do |start, length|
    value_ranges = MultiRange.new([(start..(start+length-1))])

    maps.each do |mappings|
        source_ranges = MultiRange.new([])
        destination_ranges = MultiRange.new([])

        mappings.each do |mapping|
            source_ranges |= mapping.source_range

            source_intersection = MultiRange.new([mapping.source_range]) & value_ranges
            source_intersection.ranges.each do |source_range|
                destination_range = (mapping.map(source_intersection.min)..mapping.map(source_intersection.max))
                destination_ranges |= destination_range
            end
        end

        unmapped_ranges = value_ranges - source_ranges
        value_ranges = destination_ranges | unmapped_ranges
    end

    value_ranges.min
end.min.then { puts _1 }
