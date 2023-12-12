#!/usr/bin/env ruby

Report = Struct.new(:springs, :counts)

reports = []
ARGF.each_line do |line|
    springs, counts = line.chomp.split(" ")
    springs = springs.chars
    counts = counts.split(",").map(&:to_i)

    reports << Report.new(springs, counts)
end

def matches_counts(springs, counts)
    springs.slice_when { |a, b| a != b }.filter { |g| g.all? { _1 == "#" } }.map(&:length) == counts
end

reports.map do |report|
    unknown_indexes = report.springs.each_with_index.filter { |c, i| c == "?" }.map(&:last)

    ["#", "."].repeated_permutation(unknown_indexes.length).map do |replacements|
        modified = report.springs.dup
        replacements.zip(unknown_indexes).each do |r, i|
            modified[i] = r
        end
        modified
    end.filter do |modified|
        matches_counts(modified, report.counts)
    end.length
end.sum.then { puts _1 }
