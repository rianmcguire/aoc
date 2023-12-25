#!/usr/bin/env ruby

require 'prime'

Pos = Struct.new(:x, :y, :z) do
    def +(other)
        Pos.new(*self.to_a.zip(other.to_a).map { |a,b| a + b})
    end

    def *(n)
        Pos.new(*to_a.map { _1 * n})
    end
end
Hailstone = Struct.new(:p, :v) do
    def at_t(t)
        p + v * t
    end
end

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_i)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

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
    (-300..300).filter do |vx|
        prime_power_congruences = {}
        hailstones.all? do |h, i|
            if h.v[axis] - vx == 0
                next true
            end

            a, m = find_all_solutions(-1, h.v[axis] - vx, -h.p[axis], 0, 999999999999999, 1, 999999999999999)
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

v = Pos.new(
    search(hailstones, :x).first,
    search(hailstones, :y).first,
    search(hailstones, :z).first,
)
pp v
