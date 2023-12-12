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
        # puts "#{matched.join("")}"
        if !matches_counts(matched, $original_counts)
            raise "WTF: arrangement doesn't match original counts"
        end
        return 1
    end

    if springs.empty? || counts.empty?
        return 0
    end

    space_required = counts.sum + (counts.length - 1)

    if space_required > springs.length
        # puts "not enough space"
        return 0
    end

    # puts "original: #{springs.join("")}"
    # puts "counts: #{counts.join(",")}"

    # Try to match the head of springs with the head of counts
    matched_counts = springs.slice_when { |a, b| a != b && b != "?" }.take_while { |g| !g.include?("?") }.filter { |g| g.all? { _1 == "#" } }.map(&:length)
    # puts "matched_counts: #{matched_counts.join(",")}"

    if matched_counts.any? 
        if matched_counts == counts[0...matched_counts.length]
            broken_count = 0
            matched_chunk = springs.take_while do |c|
                result = broken_count < matched_counts.sum
                broken_count += (c == "#" ? 1 : 0)
                result
            end

            if springs[...matched_chunk.length] != matched_chunk
                raise "wtf"
            end

            remaining_springs = springs[matched_chunk.length..]
            remaining_counts = counts[matched_counts.length..]

            return search(remaining_springs, remaining_counts, matched + matched_chunk, memo)
        else
            # puts "going up"
            return 0
        end
    end

    # Nothing matched - try to fit the first group into the unknown spaces
    unknown_indexes = springs.each_with_index.filter { |c, i| c == "?" }.map(&:last)

    if unknown_indexes.empty?
        return 0
    end

    count = 0

    permutation_length = [counts.first, unknown_indexes.length].min
    [".", "#"].repeated_permutation(permutation_length).each do |replacements|
        modified = springs.dup
        replacements.zip(unknown_indexes).each do |r, i|
            modified[i] = r
        end

        count += search(modified, counts, matched, memo)
    end

    # spring_chunk = springs[..chunk_index]
    # puts "chunk: #{spring_chunk.join("")}"
    # unknown_indexes = spring_chunk.each_with_index.filter { |c, i| c == "?" }.map(&:last)

    # count = 0
    # [".", "#"].repeated_permutation(unknown_indexes.length).each do |replacements|
    #     modified = spring_chunk.dup
    #     replacements.reverse.zip(unknown_indexes).each do |r, i|
    #         modified[i] = r
    #     end

    #     # puts "modified: #{modified.join("")}"

    #     if modified_counts == counts[0...modified_counts.length]


    #         # Matches prefix of counts, go deeper
    #         remaining_springs = springs[spring_chunk.length..]
    #         remaining_counts = counts[modified_counts.length..]

    #         if modified[-1] == "#" && remaining_springs[0] == "?"
    #             # raise "uh oh"
    #             remaining_springs[0] = "."
    #         end

    #         count += search(remaining_springs, remaining_counts, matched + modified, memo)
    #     end
    # end

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
