#!/usr/bin/env ruby

Report = Struct.new(:springs, :counts)

reports = []
ARGF.each_line do |line|
    springs, counts = line.chomp.split(" ")

    # Unfold
    springs = 5.times.map { springs }.join("?")
    counts = 5.times.map { counts }.join(",")

    counts = counts.split(",").map(&:to_i)

    reports << Report.new(springs, counts)
end

TYPES = [".", "#"]

def search(springs, counts, memo = {})
    # Skip over leading "." - they don't affect the result
    while springs.start_with?(".")
        springs = springs[1..]
    end

    memo_key = [springs, counts.length]
    if result = memo[memo_key]
        return result
    end

    match = springs.match(/^(#+)(\.|$)?/)
    leading_springs = match && match[1]&.length
    # A group of springs is "complete" if it's followed by a gap, or the end of string
    complete_group = match && match[2]

    result = (
        if springs.empty? && counts.empty?
            # Base case - we've matched everything!
            1
        elsif springs.empty? && !counts.empty?
            # There are no possible springs left, but there are unmatched counts
            0
        elsif leading_springs && (counts.empty? || leading_springs > counts[0])
            # Leading number of springs is bigger than the expected count - this will never match
            0
        elsif complete_group
            # Matched a complete group - check the size
            if leading_springs == counts[0]
                # Matched the first count - trim it off and go deeper
                search(springs[counts[0]..], counts[1..], memo)
            else
                # Group was a different size - this will never match
                0
            end
        elsif unknown_index = springs.index("?")
            # Explore both options for unknown value
            TYPES.sum do |c|
                modified = springs.dup
                modified[unknown_index] = c
                search(modified, counts, memo)
            end
        else
            raise "WTF: #{springs.inspect} #{counts.inspect}"
        end
    )

    memo[memo_key] = result
    result
end

reports.map do |report|
    search(report.springs, report.counts)
end.sum.then { puts _1 }
