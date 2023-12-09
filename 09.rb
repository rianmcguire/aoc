#!/usr/bin/env ruby

histories = ARGF.each_line.map do |line|
    line.chomp.split.map(&:to_i)
end

histories.map do |seq|
    # Generate difference sequences until the the values are all zero
    sequences = [seq]
    loop do
        seq = seq[1..].zip(seq).map { |b, a|  b - a }
        sequences << seq
        break if seq.all?(&:zero?)
    end

    # Work back up from the last sequence, extrapolating the next value in the previous sequence
    sequences = sequences.reverse
    sequences[1..].zip(sequences).each do |prev, curr|
        prev << prev.last + curr.last
    end

    # Get the extrapolated value in the original sequence
    sequences.last.last
end.sum.then { puts _1 }
