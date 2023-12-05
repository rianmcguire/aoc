#!/usr/bin/env ruby

require 'multi_range'

seeds, *maps = ARGF.read.split("\n\n")

seeds = seeds.split(": ").last.split(" ").map(&:to_i).each_slice(2).to_a

RangeMapping = Struct.new(:dest_start, :source_start, :length) do
    def dest_range
        (dest_start..(dest_start+length-1))
    end

    def source_range
        (source_start..(source_start+length-1))
    end

    def map(source)
        dest_start + (source - source_start)
    end

    def map_range(range)

    end
end

maps.map! do |block|
    block.lines[1..].map do |line|
        RangeMapping.new(*line.split(" ").map(&:to_i))
    end
end

class Range
    def overlap?(other)
        other.begin <= self.end && self.begin <= other.end 
    end

    def intersection(other)
      return nil if (self.max < other.begin or other.max < self.begin) 
      [self.begin, other.begin].max..[self.max, other.max].min
    end
end

def merge_ranges(ranges)
    merged = []
    ranges.sort_by {|r| r.begin}.each do |r|
      raise ArgumentError if r.exclude_end?

      if merged.empty? || merged[-1].end < r.begin
        merged << r
      else
        merged[-1] = Range.new(merged[-1].begin, [merged[-1].end, r.end].max)
      end
    end
    merged
end

seeds.map do |start, length|
    value_ranges = MultiRange.new([(start..(start+length-1))])

    maps.each_with_index do |mappings, index|
        puts "mapping #{index}"
        pp "input", value_ranges

        destination_ranges = MultiRange.new([])

        source_ranges = MultiRange.new([])
        mappings.each do |mapping|
            source_ranges |= mapping.source_range

            value_ranges.ranges.each do |range|
                source_intersection = mapping.source_range.intersection(range)
                if source_intersection
                    destination_range = (mapping.map(source_intersection.begin)..mapping.map(source_intersection.end))
                    destination_ranges |= destination_range
                end
            end
        end

        unmapped_ranges = value_ranges - source_ranges
        value_ranges = destination_ranges | unmapped_ranges
    end

    value_ranges.min
end.min.then { puts _1 }
