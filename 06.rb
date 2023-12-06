#!/usr/bin/env ruby

times, distances = ARGF.read.split("\n")
times = times.split(": ").last.split(" ").map(&:to_i)
distances = distances.split(": ").last.split(" ").map(&:to_i)

times.zip(distances).map do |race_time, record_distance|
    (1..race_time-1).map do |t|
        (race_time - t) * t
    end.count { _1 > record_distance }
end.reduce(:*).then { puts _1 }
