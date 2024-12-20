#!/usr/bin/env ruby

require 'prime'

AXIS = [:x, :y, :z]

Pos = Struct.new(*AXIS)
Hailstone = Struct.new(:p, :v)

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_i)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

def outwards_from_zero
    Enumerator.new do |yielder|
        n = 1
        loop do
            yielder << n
            yielder << -n
            n += 1
        end
    end
end

# Try a range of rock speeds on a single axis, see if it's possible that a rock with that speed would be able to hit
# all hailstones.
#
# TODO: The example input (but not the full input) has multiple solutions for each axis. There are probably some more
# cases that need to be detected and excluded as impossible. It works well enough now as the first case that matches
# is the one we want.
def find_v(hailstones, axis)
    outwards_from_zero.find do |rock_v|
        # The rock and a hailstone collide (on this axis) when:
        # rock_p + rock_v * t = hailstone_p + hailstone_v * t
        #
        # Re-arrange to get:
        # rock_p = hailstone_p + t * (hailstone_v - rock_v)
        #
        # There is more than one solution, because the exact value depends on the value of t for this hailstone (which
        # we don't know), but as long as they're both positioned at some multiple of the speed difference
        # (hailstone_v - rock_v), they will be able to collide.
        #
        # That gives us this congruence:
        # rock_p ≡ hailstone_p (mod hailstone_v - rock_v)
        #
        # Across all hailstones, the rock_p must be the same, so we have a "system of congruences". If all hailstones
        # have a congruent rock_p with this rock_v, we've found a valid speed for this axis.

        # Special case: the hailstone and the rock have the same speed. This speed could still be valid, as long as the
        # rock and the hailstone start at the same position on this axis.
        known_rock_ps = hailstones.filter { |h| h.v[axis] == rock_v }.map { |h| h.p[axis] }
        if known_rock_ps.uniq.length > 1
            # There are multiple hailstones with the same speed that would require different rock positions.
            # This speed won't work.
            next false
        end
        known_rock_p = known_rock_ps.first

        # https://stackoverflow.com/questions/24740533/determining-whether-a-system-of-congruences-has-a-solution
        prime_power_congruences = {}
        hailstones.all? do |h, i|
            # x ≡ a (mod n)
            a = h.p[axis]
            n = h.v[axis] - rock_v

            # Same speed - this is handled via known_rock_p
            next true if n == 0

            # If we have a special case "same speed" hailstone that fixes the rock position, ensure that position is
            # still congruent with the other hailstones.
            if known_rock_p && (known_rock_p % n) != (a % n)
                next false
            end

            # Apply the https://en.wikipedia.org/wiki/Chinese_remainder_theorem to check if there's a solution to the
            # system of congruences. To do that, the moduluses need to be coprime. Factor each modulus into its prime
            # powers, and check for compatibility as we go.
            result = true
            Prime.prime_division(n).each do |p, e|
                pe = p ** e
                new_ppc = [pe, a % pe]
                if old_ppc = prime_power_congruences[p]
                    if !compatible(new_ppc, old_ppc)
                        result = false
                        break
                    else
                        prime_power_congruences[p] = [new_ppc, old_ppc].max
                    end
                else
                    prime_power_congruences[p] = new_ppc
                end
            end

            result
        end
    end
end

def compatible(old_ppc, new_ppc)
    # Is x ≡ a (mod m) compatible with x ≡ b (mod n)?
    m, a = old_ppc
    n, b = new_ppc
    (a - b) % ([m, n].min) == 0
end

# Find the velocity of the rock through congruences
rock_v = Pos.new(
    find_v(hailstones, :x),
    find_v(hailstones, :y),
    find_v(hailstones, :z),
)

# If a hailstone has the same velocity component as the rock, the rock must start in the same position on that
# axis, otherwise they would never collide. We can use this fact to bootstrap our solution.
rock_p = Pos.new
hailstones.each do |h|
    AXIS.each do |axis|
        if h.v[axis] == rock_v[axis]
            rock_p[axis] = h.p[axis]
        end
    end
end

# We have enough information to calculate the time of collision for an arbitrary hailstone now
known_axis = AXIS.find { rock_p[_1] }
h = hailstones.find { |h| h.v[known_axis] != rock_v[known_axis] }
t = (h.p[known_axis] - rock_p[known_axis]) / (rock_v[known_axis] - h.v[known_axis])

# Fill in any starting values we don't have
AXIS.each do |axis|
    next if rock_p[axis]
    rock_p[axis] = h.p[axis] + h.v[axis] * t - rock_v[axis] * t
end

puts rock_p.to_a.sum
