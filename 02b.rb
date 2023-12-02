#!/usr/bin/env ruby


def minimum(rounds)
    max = Hash.new {|h,k| h[k] = 0}

    rounds = rounds.split ";"
    rounds.each do |round|
        cubes = round.split ","
        cubes.each do |cube|
            count, color = cube.split " "
            count = count.to_i

            max[color] = count if count > max[color]
        end
    end

    max
end

def power(set)
    set.values.reduce(:*)
end

ARGF.each_line.map do |line|
    game, rounds = line.split ":"
    _, id = game.split " "

    power(minimum(rounds))
end.sum.then {|result| puts result }
