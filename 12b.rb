#!/usr/bin/env ruby

Report = Struct.new(:springs, :counts)

reports = []
ARGF.each_line do |line|
    springs, counts = line.chomp.split(" ")

    # Unfold
    springs = 5.times.map { springs }.join("?")
    counts = 5.times.map { counts }.join(",")

    springs = springs.chars
    counts = counts.split(",").map(&:to_i)

    reports << Report.new(springs, counts)
end

def matches_counts(springs, counts)
    springs.slice_when { |a, b| a != b }.filter { |g| g.all? { _1 == "#" } }.map(&:length) == counts
end

def search(springs, counts, matched = [], memo = {})
    if memo[[springs, counts]]
        return memo[[springs, counts]]
    end

    if (springs.count { _1 == "#"} == 0) && counts.empty?
        # if !matches_counts(matched, $original_counts)
        #     raise "WTF: arrangement doesn't match original counts"
        # end
        return 1
    end

    if springs.empty? || counts.empty?
        return 0
    end

    space_required = counts.sum + (counts.length - 1)

    if space_required > springs.length
        return 0
    end

    # First group doesn't have a confirmed length yet, but it's bigger than the expected count
    first_group = springs.join.match(/^\.*(#+)\?/)
    if first_group && first_group[1].length > counts[0]
        return 0
    end

    # Try to match the head of springs with the head of counts
    matched_counts = springs.slice_when { |a, b| a != b && b != "?" }.take_while { |g| !g.include?("?") }.filter { |g| g.all? { _1 == "#" } }.map(&:length)

    if matched_counts.any? 
        if matched_counts == counts[0...matched_counts.length]
            broken_count = 0
            matched_chunk = springs.take_while do |c|
                result = broken_count < matched_counts.sum
                broken_count += (c == "#" ? 1 : 0)
                result
            end

            # if springs[...matched_chunk.length] != matched_chunk
            #     raise "wtf"
            # end

            remaining_springs = springs[matched_chunk.length..]
            remaining_counts = counts[matched_counts.length..]

            return search(remaining_springs, remaining_counts, matched, memo)
        else
            return 0
        end
    end

    # Nothing matched - try to fit the first group into the unknown spaces
    unknown_indexes = springs.each_with_index.filter { |c, i| c == "?" }.map(&:last)

    if unknown_indexes.empty?
        return 0
    end

    count = 0

    # TODO: stop using permutations and "slide" the first group length across the unknowns
    permutation_length = [counts.first, unknown_indexes.length].min
    [".", "#"].repeated_permutation(permutation_length).each do |replacements|
        modified = springs.dup
        replacements.zip(unknown_indexes).each do |r, i|
            modified[i] = r
        end

        count += search(modified, counts, matched, memo)
    end

    memo[[springs, counts]] = count
    count
end

reports.map do |report|
    puts report.springs.join("")
    puts report.counts.join(",")
    $original_counts = report.counts
    result = search(report.springs, report.counts)
    puts result
    puts
    result
end.sum.then { puts _1 }
