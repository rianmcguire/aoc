#!/usr/bin/env ruby

copies = Hash.new { |h,k| h[k] = 1}

cards = ARGF.each_line.to_a

cards.each_with_index do |line, index|
    index = index + 1
    card, all_numbers = line.chomp.split ":"
    winning, own = all_numbers.split(" | ")
    winning = winning.split(" ")
    own = own.split(" ")

    count = (winning & own).length

    ((index + 1)..(index + count)).each do |i|
        copies[i] += copies[index]
    end
end

puts copies.values.sum
