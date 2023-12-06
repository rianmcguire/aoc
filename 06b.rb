#!/usr/bin/env ruby

times, distances = ARGF.read.split("\n")
race_time = times.split(": ").last.gsub(" ", "").to_i
record_distance = distances.split(": ").last.gsub(" ", "").to_i

(1..race_time-1).map do |t|
    (race_time - t) * t
end.count { _1 > record_distance }.then { puts _1 }
