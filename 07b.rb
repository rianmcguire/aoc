#!/usr/bin/env ruby

CARD_STRENGTH = %w(A K Q T 9 8 7 6 5 4 3 2 J).reverse

def score(cards)
    tally = cards.chars.tally.values.sort.reverse

    if tally == [5]
        # Five of a kind
        6
    elsif tally == [4, 1]
        # Four of a kind
        5
    elsif tally == [3, 2]
        # Full house
        4
    elsif tally == [3, 1, 1]
        # Three of a kind
        3
    elsif tally == [2, 2, 1]
        # Two pair
        2
    elsif tally == [2, 1, 1, 1]
        # One pair
        1
    else
        # High card
        0
    end
end

Hand = Struct.new(:cards, :bid, keyword_init: true) do
    include Comparable

    def type
        j_indexes = cards.chars.each_with_index.filter { |c, index| c == "J" }.map(&:last)
        CARD_STRENGTH.repeated_combination(j_indexes.length).map do |replacements|
            modified = cards.dup
            replacements.zip(j_indexes).each do |r, i|
                modified[i] = r
            end
            modified
        end.map { score(_1) }.max
    end

    def card_strengths
        cards.chars.map { CARD_STRENGTH.index(_1) }
    end

    def <=>(other)
        [self.type, self.card_strengths] <=> [other.type, other.card_strengths]
    end
end

hands = ARGF.each_line.map do |line|
    cards, bid = line.chomp.split(" ")
    bid = bid.to_i

    Hand.new(cards:, bid:)
end

puts hands.sort.each_with_index.map { |hand, index| hand.bid * (index + 1) }.sum
