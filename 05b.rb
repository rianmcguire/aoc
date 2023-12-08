#!/usr/bin/env ruby

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'multi_range', '2.2.1', require: true
end

seeds, *maps = ARGF.read.split("\n\n")

seeds = seeds.split(": ").last.split(" ").map(&:to_i).each_slice(2).to_a

RangeMapping = Struct.new(:dest_start, :source_start, :length) do
    def source_range
        (source_start..(source_start+length-1))
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

seeds.map do |start, length|
    # Start with the seed range
    value_ranges = MultiRange.new([(start..(start+length-1))])

    # Run the range through each of the maps in order
    maps.each do |mappings|
        # Calculate the destination ranges that are possible through each range mapping
        destination_ranges = MultiRange.new([])
        mappings.each do |mapping|
            source_intersection = MultiRange.new([mapping.source_range]) & value_ranges
            if source_intersection.any?
                # Map any values that are covered by this mapping to a destination range
                destination_range = (mapping.transform(source_intersection.min)..mapping.transform(source_intersection.max))
                destination_ranges |= destination_range
            end
        end

        # Any values that aren't covered by the source ranges in this map are passed through unchanged
        source_ranges = MultiRange.new(mappings.map(&:source_range))
        unmapped_ranges = value_ranges - source_ranges

        value_ranges = destination_ranges | unmapped_ranges
    end

    # Whis is the final value ("location") for this seed?
    value_ranges.min
end.min.then { puts _1 }
