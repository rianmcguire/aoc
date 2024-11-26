#!/usr/bin/env ruby

Pos = Struct.new(:x, :y, :z) do
    def +(other)
        Pos.new(*self.to_a.zip(other.to_a).map { |a,b| a + b})
    end

    def *(other)
        Pos.new(*to_a.map { _1 * other})
    end
end
Hailstone = Struct.new(:p, :v)

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_f)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

# https://stackoverflow.com/a/63577437
def ray_intersection(as, ad, bs, bd)
    if as == bs
        return as
    end

    dx = bs.x - as.x
    dy = bs.y - as.y
    det = bd.x * ad.y - bd.y * ad.x
    if det != 0 
        u = (dy * bd.x - dx * bd.y) / det;
        v = (dy * ad.x - dx * ad.y) / det;
        if u >= 0 && v >= 0
            return as + ad * u
        end
    end
    
    nil
end

# test_area = (7..27)
test_area = (200000000000000..400000000000000)

hailstones.combination(2).count do |a, b|
    i = ray_intersection(a.p, a.v, b.p, b.v)

    i && test_area.include?(i.x) && test_area.include?(i.y)
end.then { puts _1 }
