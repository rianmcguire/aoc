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
end

hailstones = ARGF.each_line.map do |line|
    numbers = line.chomp.scan(/[\-\d]+/).map(&:to_i)
    Hailstone.new(Pos.new(*numbers[0..2]), Pos.new(*numbers[3..]))
end

hailstones.each_with_index do |h,i|
    puts "h#{i}[t_] := {#{h.p.to_a.join(", ")}} + t * {#{h.v.to_a.join(", ")}}"
end
puts "r[t_] := {px, py, pz} + t * {vx, vy, vz}"
puts "Solve["
puts hailstones.each_with_index.map { |h, i| "h#{i}[t#{i}] == r[t#{i}] && t#{i} > 0"}.join(" && ")
puts ", {px, py, pz}, Integers]"
