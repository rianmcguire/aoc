#!/usr/bin/env ruby

def prune(n)
  n % 2**24
end

# https://en.wikipedia.org/wiki/Xorshift
def next_number(n)
  n = prune(n ^ n * 64)
  n = prune(n ^ n / 32)
  n = prune(n ^ n * 2048)
end

initials = ARGF.each_line(chomp: true).map(&:to_i)

initials.sum do |n|
  2000.times.inject(n) do |n, _|
    next_number(n)
  end
end.then { puts _1 }
