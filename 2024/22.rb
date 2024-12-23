#!/usr/bin/env ruby

RubyVM::YJIT.enable

MASK = 2**24 - 1
def prune(n)
  n & MASK
end

# https://en.wikipedia.org/wiki/Xorshift
def next_number(n)
  n = prune(n ^ n << 6)
  n = prune(n ^ n >> 5)
  n = prune(n ^ n << 11)
end

initials = ARGF.each_line(chomp: true).map(&:to_i)

initials.sum do |n|
  2000.times { n = next_number(n) }
  n
end.then { puts _1 }
