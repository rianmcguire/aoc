#!/usr/bin/env ruby

times, distances = ARGF.read.split("\n")
# Ignore spaces and treat the times and distances as a single number
race_time = times.split(": ").last.gsub(" ", "").to_i
record_distance = distances.split(": ").last.gsub(" ", "").to_i


# Analytical solution
# r = race time
# t = hold duration
# d = record distance
# distance travelled in race = (r - t) * t
#
# Solve for t:
# (r - t) * t >= d + 1
#
# Wolfram Alpha says:
# 1/2 (r - sqrt(-4 d + r^2 - 4)) <= t <= 1/2 (sqrt(-4 d + r^2 - 4) + r)
min_t = (0.5 * (race_time - Math.sqrt(-4 * record_distance + race_time * race_time - 4))).ceil
max_t = (0.5 * (race_time + Math.sqrt(-4 * record_distance + race_time * race_time - 4))).floor
puts max_t - min_t + 1

# Brute force solution
# # For each possible button hold duration (t)
# (1..race_time-1)
#     # Calculate the duration travelled
#     .map { |t| (race_time - t) * t }
#     # And count it if it beat the record
#     .count { _1 > record_distance }
#     .then { puts _1 }
