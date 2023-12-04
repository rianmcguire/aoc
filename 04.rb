#!/usr/bin/env ruby

ARGF.each_line.map do |line|
    card, all_numbers = line.chomp.split ":"
    winning, own = all_numbers.split(" | ")
    winning = winning.split(" ")
    own = own.split(" ")

    count = (winning & own).length

    if count > 0
        2 ** ((winning & own).length - 1)
    else
        0
    end
end.sum.then { puts _1 }
