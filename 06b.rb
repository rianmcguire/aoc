#!/usr/bin/env ruby

times, distances = ARGF.read.split("\n")
# Ignore spaces and treat the times and distances as a single number
race_time = times.split(": ").last.gsub(" ", "").to_i
record_distance = distances.split(": ").last.gsub(" ", "").to_i

# For each possible button hold duration (t)
(1..race_time-1)
    # Calculate the duration travelled
    .map { |t| (race_time - t) * t }
    # And count it if it beat the record
    .count { _1 > record_distance }
    .then { puts _1 }
