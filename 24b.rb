#!/usr/bin/env ruby

require 'prime'

AXIS = [:x, :y, :z]

Pos = Struct.new(*AXIS)
Hailstone = Struct.new(:p, :v)

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_i)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

# https://cp-algorithms.com/algebra/linear-diophantine-equation.html
def gcd(a, b)
    if b == 0
        x = 1
        y = 0
        return [a, x, y]
    end

    d, x1, y1 = gcd(b, a % b)
    x = y1
    y = x1 - y1 * (a / b)

    return [d, x, y]
end

def find_any_solution(a, b, c)
    g, x0, y0 = gcd(a.abs, b.abs)
    return nil if c % g != 0

    x0 *= c / g
    y0 *= c / g
    x0 = -x0 if a < 0
    y0 = -y0 if b < 0

    [x0, y0, g]
end

def shift_solution(x, y, a, b, cnt)
    x += cnt * b
    y -= cnt * a

    [x, y]
end

def find_all_solutions(a, b, c, minx, maxx, miny, maxy)
    x, y, g = find_any_solution(a, b, c)
    return 0 if !x
    a /= g
    b /= g

    sign_a = a > 0 ? +1 : -1
    sign_b = b > 0 ? +1 : -1

    x, y = shift_solution(x, y, a, b, (minx - x) / b)
    if x < minx
        x, y = shift_solution(x, y, a, b, sign_b)
    end
    if x > maxx
        return 0
    end
    lx1 = x

    x, y = shift_solution(x, y, a, b, (maxx - x) / b)
    if x > maxx
        x, y = shift_solution(x, y, a, b, -sign_b)
    end
    rx1 = x

    x, y = shift_solution(x, y, a, b, -(miny - y) / a)
    if y < miny
        x, y = shift_solution(x, y, a, b, -sign_a)
    end
    if y > maxy
        return 0
    end
    lx2 = x

    x, y = shift_solution(x, y, a, b, -(maxy - y) / a)
    if y > maxy
        x, y = shift_solution(x, y, a, b, sign_a)
    end
    rx2 = x

    if lx2 > rx2
        temp = lx2
        lx2 = rx2
        rx2 = temp
    end
    lx = [lx1, lx2].max
    rx = [rx1, rx2].min

    # puts "lx=#{lx}"
    # puts "g=#{g}"
    # puts "x = #{lx} + k * #{b / g}"
    #     y = (c - a * x) / b

    # if lx > rx
    #     return nil
    # end
    # return (rx - lx) / b.abs + 1

    [lx, b / g]
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

def search(hailstones, axis)
    # TODO: derive this range
    (-300..300).filter do |vx|
        prime_power_congruences = {}
        hailstones.all? do |h, i|
            if h.v[axis] - vx == 0
                next true
            end

            # TODO: remove these limits and maybe the whole find_all_solutions thing. I think it all boils down to some
            # gcd stuff
            a, m = find_all_solutions(-1, h.v[axis] - vx, -h.p[axis], 0, 999999999999999, 1, 999999999999999)
            # px = a mod m
            # x = a mod m

            # https://stackoverflow.com/questions/24740533/determining-whether-a-system-of-congruences-has-a-solution
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
# TODO: why does the example data have multiple solutions for each axis? Is something wrong, or should we be searching them?
rock_v = Pos.new(
    search(hailstones, :x).first,
    search(hailstones, :y).first,
    search(hailstones, :z).first,
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
