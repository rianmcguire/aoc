#!/usr/bin/env ruby

# Calculate the minimum number of cubes of each color to make a game possible, which is the maximum number seen
# for each color
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

# The power of a set of cubes is equal to the numbers of red, green, and blue cubes multiplied together
def power(set)
    set.values.reduce(:*)
end

ARGF.each_line.map do |line|
    _, rounds = line.split ":"

    power(minimum(rounds))
end.sum.then { puts _1 }
