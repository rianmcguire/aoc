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

def seq(n, length)
  Enumerator.new do |yielder|
    length.times do
      yielder << n
      n = next_number(n)
    end
  end
end

initials = ARGF.each_line(chomp: true).map(&:to_i)

PATTERN_LEN = 4

all_sale_prices = {}
initials.each do |n|
  sale_prices = {}

  prices = seq(n, 2000 + 1).map { _1 % 10 }

  # Run through the sequence and compute a rolling "hash" that identifies the last 4 price changes
  h = 0
  prices.drop(1).zip(prices).each do |b, a|
    diff = b - a
    # The diffs can range from -9 to 9 (19 values), which we can represent in 5 bits.
    # Shift the diff values through, keeping the last 4*5 = 20 bits
    h = ((h << 5) | (diff + 9)) % 2**(5*PATTERN_LEN)

    # Record the first price we saw with this change sequence
    sale_prices[h] ||= b
  end

  # Total up the prices for each change sequence
  all_sale_prices.merge!(sale_prices) { |h, old, new| old + new }
end

puts all_sale_prices.values.max
