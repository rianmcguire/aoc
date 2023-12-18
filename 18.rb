#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
    def step(dir)
        case dir
        when "U"
            Pos.new(x, y - 1)
        when "D"
            Pos.new(x, y + 1)
        when "R"
            Pos.new(x + 1, y)
        when "L"
            Pos.new(x - 1, y)
        end
    end
end

pos = Pos.new(0, 0)

holes = Set.new([pos])
first_dir = nil
ARGF.each_line do |line|
    dir, dist, color = line.chomp.split(" ")
    dist = dist.to_i

    first_dir ||= dir

    dist.times do
        pos = pos.step(dir)
        holes << pos
    end
end

def flood(holes, pos)
    stack = [pos]

    until stack.empty?
        pos = stack.pop

        next if holes.include?(pos)

        holes << pos

        ["U", "D", "L", "R"].each do |dir|
            new_pos = pos.step(dir)
            stack << new_pos
        end
    end
end

# TODO: lol
flood(holes, Pos.new(0, 0).step("D").step("R"))

pp holes.length
