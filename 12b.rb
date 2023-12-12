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

def search(springs, counts, memo = {})
    if memo[[springs, counts]]
        return memo[[springs, counts]]
    end

    result = (
        if springs.start_with?(".")
            # Skip over leading "." - they don't affect the counts
            search(springs[1..], counts, memo)
        elsif springs.empty? && counts.empty?
            # Base case - we've matched everything!
            1
        elsif springs.empty? && !counts.empty?
            # There are no possible springs left, but there are unmatched counts
            0
        elsif (match = springs.match(/^(#+)/)) && (counts.empty? || match[1].length > counts[0])
            # Leading number of springs is bigger than the expected count - this will never match
            0
        elsif (match = springs.match(/^(#+)(\.|$)/))
            # Matched a complete group - check the size
            if match[1].length == counts[0]
                # Matched the first count - trim it off and go deeper
                search(springs[counts[0]..], counts[1..], memo)
            else
                # Group was a different size - this will never match
                0
            end
        elsif unknown_index = springs.index("?")
            # Explore both options for unknown value
            [".", "#"].sum do |c|
                modified = springs.dup
                modified[unknown_index] = c
                search(modified, counts, memo)
            end
        else
            raise "WTF: #{springs.inspect} #{counts.inspect}"
        end
    )

    memo[[springs, counts]] = result
    result
end

reports.map do |report|
    search(report.springs, report.counts)
end.sum.then { puts _1 }
