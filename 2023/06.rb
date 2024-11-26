#!/usr/bin/env ruby

times, distances = ARGF.read.split("\n")
times = times.split(": ").last.split(" ").map(&:to_i)
distances = distances.split(": ").last.split(" ").map(&:to_i)

times.zip(distances).map do |race_time, record_distance|
    # For each possible button hold duration (t)
    (1..race_time-1)
        # Calculate the duration travelled
        .map { |t| (race_time - t) * t }
        # And count it if it beat the record
        .count { _1 > record_distance }
end.reduce(:*).then { puts _1 }
