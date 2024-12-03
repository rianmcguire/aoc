#!/usr/bin/env ruby

input = ARGF.read
input.scan(/mul\((\d+),(\d+)\)/).sum do |s|
  a, b = s.map(&:to_i)
  a * b
end.then { puts _1 }
