#!/usr/bin/env ruby

ARGF.each_line.map do |line|
    # Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    card, all_numbers = line.chomp.split ":"
    winning, own = all_numbers.split(" | ")
    winning = winning.split(" ")
    own = own.split(" ")

    matches = (winning & own).length

    if matches > 0
        # The first match makes the card worth one point and each match after the first doubles the point
        # value of that card
        2 ** (matches - 1)
    else
        0
    end
end.sum.then { puts _1 }
