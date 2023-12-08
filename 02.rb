#!/usr/bin/env ruby

def possible?(rounds)
    rounds = rounds.split ";"
    rounds.each do |round|
        cubes = round.split ","
        cubes.each do |cube|
            count, color = cube.split " "
            count = count.to_i

            # Game is not possible if a round revealed more than 12/13/14 of the particular colors
            return false if (
                color == "red" && count > 12 ||
                color == "green" && count > 13 ||
                color == "blue" && count > 14
            )
        end
    end

    return true
end

possible = []
ARGF.each_line do |line|
    game, rounds = line.split ":"
    _, id = game.split " "

    if possible?(rounds)
        possible << id.to_i
    end
end

puts possible.sum
