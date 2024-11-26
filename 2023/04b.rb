#!/usr/bin/env ruby

cards = ARGF.each_line.to_a

# Track the numbers of copies of each card
copies = Array.new(cards.length, 1)

cards.each_with_index do |line, card_index|
    # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    card, all_numbers = line.chomp.split ":"
    winning, own = all_numbers.split(" | ")
    winning = winning.split(" ")
    own = own.split(" ")

    matches = (winning & own).length

    # You win copies of the scratchcards below the winning card equal to the number of matches
    ((card_index + 1)..(card_index + matches)).each do |i|
        copies[i] += copies[card_index]
    end
end

puts copies.sum
