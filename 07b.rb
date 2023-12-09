#!/usr/bin/env ruby

# Hash of card to strength value
CARD_STRENGTH = %w(A K Q T 9 8 7 6 5 4 3 2 J).reverse.each_with_index.to_h

# Determine type strength for a cards string
def cards_type(cards)
    tally = cards.chars.tally.values.sort

    if tally == [5]
        # Five of a kind
        6
    elsif tally == [1, 4]
        # Four of a kind
        5
    elsif tally == [2, 3]
        # Full house
        4
    elsif tally == [1, 1, 3]
        # Three of a kind
        3
    elsif tally == [1, 2, 2]
        # Two pair
        2
    elsif tally == [1, 1, 1, 2]
        # One pair
        1
    else
        # High card
        0
    end
end

Hand = Struct.new(:cards, :bid_string) do
    include Comparable

    def type
        # Find location of all jokers
        j_indexes = cards.chars.each_with_index.filter { |c, index| c == "J" }.map(&:last)

        # Try ever possible combination of cards that could replace the jokers, and return the maximum type stength
        CARD_STRENGTH.keys.repeated_combination(j_indexes.length).map do |replacements|
            modified = cards.dup
            replacements.zip(j_indexes).each do |r, i|
                modified[i] = r
            end
            cards_type(modified)
        end.max
    end

    def card_strengths
        cards.chars.map { CARD_STRENGTH.fetch(_1) }
    end

    def bid
        bid_string.to_i
    end

    def sort_key
        @sort_key ||= [self.type, self.card_strengths]
    end

    def <=>(other)
        self.sort_key <=> other.sort_key
    end
end

# Parse hands
hands = ARGF.each_line.map do |line|
    Hand.new(*line.chomp.split(" "))
end

hands
    # Sort hands in increasing strength
    .sort
    # Score each hand by multiplying its bid with its rank
    .each_with_index.map { |hand, index| hand.bid * (index + 1) }
    # Total winnings
    .sum.then { puts _1 }
