#!/usr/bin/env ruby

ARGF.read.chomp.split(",").map do |step|
    value = 0
    step.chars.each do |c|
        value += c.ord
        value *= 17
        value = value % 256
    end
    value
end.sum.then { puts _1 }
