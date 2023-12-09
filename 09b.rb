#!/usr/bin/env ruby

sequences = ARGF.each_line.map do |line|
    line.chomp.split.map(&:to_i).reverse
end

sequences.map do |seq|
    histories = [seq]
    loop do
        seq = seq[1..].zip(seq).map { |b, a|  b - a }
        histories << seq

        break if seq.all?(&:zero?)
    end

    histories = histories.reverse

    histories[1..].zip(histories).each do |b, a|
        b << b.last + a.last
    end

    histories.last.last
end.sum.then { puts _1 }