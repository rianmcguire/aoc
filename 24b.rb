#!/usr/bin/env ruby

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

    # def min_px(vx)
    #     t = 1
    #     p.x + v.x * t - vx * t
    # end

    def min_px(vx)
        min_p(vx, :x)
    end

    def min_p(va, axis)
        t = 1
        p[axis] + v[axis] * t - va * t
    end

    def t_for(vx, px)
        (-p.x + px) / (v.x - vx)
    end
end

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_i)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

def search(hailstones)
    (-300..-1).each do |vx|
        puts "vx #{vx}"
        axis = :x

        # Can't have a vector identical to a hailstone
        next if hailstones.any? {|h| h.v.x == vx}

        range = if vx > 0
            raise "TODO"
            # min_px = hailstones.map do |h|
            #     h.min_p(vx, axis)
            # end.min

            # # If we have a positive vector, need to be positioned below negative vectors
            # max_px = hailstones.filter_map do |h|
            #     h.v.x < 0 && h.v.x
            # end.min

            # min_px..max_px
        else
            # If we have a negative vector, need to be positioned above any positive vectors
            min_px = hailstones.filter_map do |h|
                h.v.x > 0 && h.v.x
            end.max

            # max_px = hailstones.map do |h|
                # Is it moving towards us, or away from us?
            #     h.min_p(vx, axis)
            # end.max

            # Generally must be below any vectors that are more negative than us
            max_px = hailstones.filter { |h| h.v.x < 0 && h.v.x < vx }.map { |h| h.p.x }.min

            # And higher than any vectors if we're more negative than them
            x = hailstones.filter { |h| h.v.x < 0 && vx < h.v.x }.map { |h| h.p.x }.max
            if x && x > min_px
                min_px = x
            end

            min_px..max_px
        end

        # if range.size > 0
            # puts "vx #{vx}"
            pp range
        # end

        # What's the maximum time?

        # Paths need to not diverge

        # px = [min_px].find do |px|
        #     puts "px #{px}"
        #     ts = hailstones.map do |h|
        #         next if (h.v[axis] - vx) == 0
        #         t = (-h.p[axis] + px) / (h.v[axis] - vx)
        #         t > 0 && t
        #     end
        #     # pp ts

        #     ts.all? { |t| t } && ts.uniq.length == hailstones.length
        # end
    
        # return [vx, px] if px
    end
end

vx, px = search(hailstones)

# pp vx, px

# pp(hailstones.map do |h|
#     h.v.x
# end.minmax)

# Must intersect every hailstone at an integer time
#   - Does this imply something about odd/even/multiples?
#   - https://en.wikipedia.org/wiki/Diophantine_equation
#   - https://en.wikipedia.org/wiki/B%C3%A9zout%27s_identity
# Selected vector must not equal any of the others
# Paths need to not diverge
#   - if we have a negative vector, need to be positioned above any positive vectors
#   - if we have a positive vector, need to be positioned below negative vectors

# def gcd(a, b)
#     if b == 0
#         x = 1
#         y = 0
#         return [a, x, y]
#     end

#     d, x1, y1 = gcd(b, a % b)
#     x = y1
#     y = x1 - y1 * (a / b)

#     return [d, x, y]
# end

# def find_any_solution(a, b, c)
#     g, x0, y0 = gcd(a.abs, b.abs)
#     return nil if c % g != 0

#     x0 *= c / g
#     y0 *= c / g
#     x0 = -x0 if a < 0
#     y0 = -y0 if b < 0

#     [x0, y0, g]
# end

# def shift_solution(x, y, a, b, cnt)
#     x += cnt * b
#     y -= cnt * a

#     [x, y]
# end

# def find_all_solutions(a, b, c, minx, maxx, miny, maxy)
#     x, y, g = find_any_solution(a, b, c)
#     return 0 if !x
#     a /= g
#     b /= g

#     sign_a = a > 0 ? +1 : -1
#     sign_b = b > 0 ? +1 : -1

#     x, y = shift_solution(x, y, a, b, (minx - x) / b)
#     if x < minx
#         x, y = shift_solution(x, y, a, b, sign_b)
#     end
#     if x > maxx
#         return 0
#     end
#     lx1 = x

#     x, y = shift_solution(x, y, a, b, (maxx - x) / b)
#     if x > maxx
#         x, y = shift_solution(x, y, a, b, -sign_b)
#     end
#     rx1 = x

#     x, y = shift_solution(x, y, a, b, -(miny - y) / a)
#     if y < miny
#         x, y = shift_solution(x, y, a, b, -sign_a)
#     end
#     if y > maxy
#         return 0
#     end
#     lx2 = x

#     x, y = shift_solution(x, y, a, b, -(maxy - y) / a)
#     if y > maxy
#         x, y = shift_solution(x, y, a, b, sign_a)
#     end
#     rx2 = x

#     if lx2 > rx2
#         temp = lx2
#         lx2 = rx2
#         rx2 = temp
#     end
#     lx = [lx1, lx2].max
#     rx = [rx1, rx2].min

#     puts "lx=#{lx}"
#     puts "g=#{g}"

#     (0..10).each do |k|
#         x = lx + k * b / g
#         y = (c - a * x) / b
#         pp [x, y]
#         pp a * x + b * y == c
#     end

#     if lx > rx
#         return 0
#     end
#     return (rx - lx) / b.abs + 1
# end

# find_all_solutions(5, 3, 4, 0, 9999, 19, 9999)
