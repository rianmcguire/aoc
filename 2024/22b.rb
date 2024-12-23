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

PATTERN_LEN = 4
DIFF_BIT_LENGTH = 5
HASH_MASK = 2**(DIFF_BIT_LENGTH*PATTERN_LEN) - 1

all_sale_prices = {}
initials.each do |n|
  sale_prices = {}

  # Run through the sequence and compute a rolling "hash" that identifies the last 4 price changes
  h = 0
  prev_price = nil
  2001.times do
    price = n % 10

    if prev_price
      diff = price - prev_price

      # The diffs can range from -9 to 9 (19 values), which we can represent in 5 bits.
      # Shift the diff values through, keeping the last 4*5 = 20 bits
      h = ((h << DIFF_BIT_LENGTH) | (diff + 9)) & HASH_MASK

      # Record the first price we saw with this change sequence
      sale_prices[h] ||= price
    end

    prev_price = price

    n = next_number(n)
  end

  # Total up the prices for each change sequence
  all_sale_prices.merge!(sale_prices) { |h, old, new| old + new }
end

puts all_sale_prices.values.max
