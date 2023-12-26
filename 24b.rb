#!/usr/bin/env ruby

require 'prime'

AXIS = [:x, :y, :z]

Pos = Struct.new(*AXIS)
Hailstone = Struct.new(:p, :v)

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_i)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

def compatible(old_ppc, new_ppc)
    m, a = old_ppc
    n, b = new_ppc
    (a - b) % ([m, n].min) == 0
end

# TODO: replace this with Prime.prime_division. why doesn't it give the same results?
def prime_power_factorisation(n)
    while n > 1
        p = (2...n+1).filter { n % _1 == 0 }.first
        pe = 1
        while n % p == 0
            n = n / p
            pe = pe*p
        end
        yield [p, pe]
    end
end

# Try a range of rock speeds on a single axis, see if it's possible that a rock with that speed would be able to hit
# all hailstones.
def find_v(hailstones, axis)
    # TODO: derive this range
    (-300..300).filter do |rock_v|
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
        # Across all hailstones, the rock_p must be the same, so we have a system of congruences. If all hailstones
        # have a congruent rock_p under this rock_v, we've found a valid speed for this axis.

        # https://stackoverflow.com/questions/24740533/determining-whether-a-system-of-congruences-has-a-solution
        prime_power_congruences = {}
        hailstones.all? do |h, i|
            # x ≡ a (mod m)
            a = h.p[axis]
            m = h.v[axis] - rock_v

            if m == 0
                # The hailstone and the rock have the same speed. That's not a problem as long as they start in the
                # same position on this axis.
                next true
            end

            a = a.abs
            m = m.abs
            result = true
            prime_power_factorisation(m) do |p, pe|
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

# Find the velocity of the rock through congruences
# TODO: why does the example data have multiple solutions for each axis? Is something wrong, or should we be searching
# for valid combinations?
rock_v = Pos.new(
    find_v(hailstones, :x).first,
    find_v(hailstones, :y).first,
    find_v(hailstones, :z).first,
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
h = hailstones.first
known_axis = AXIS.find { rock_p[_1] }
t = (h.p[known_axis] - rock_p[known_axis]) / (rock_v[known_axis] - h.v[known_axis])

# Fill in any starting values we don't have
AXIS.each do |axis|
    next if rock_p[axis]
    rock_p[axis] = h.p[axis] + h.v[axis] * t - rock_v[axis] * t
end

puts rock_p.to_a.sum
