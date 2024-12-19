#!/usr/bin/env ruby

available, designs = ARGF.read.split("\n\n")
available = available.chomp.split(", ")
designs = designs.each_line.map(&:chomp)

regexp = Regexp.new("^(#{available.join("|")})+$")
puts designs.count { regexp.match?(_1) }
