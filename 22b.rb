#!/usr/bin/env ruby

Pos = Struct.new(:x, :y, :z) do
    def on_ground?
        z == 1
    end

    def drop
        Pos.new(x, y, z - 1)
    end
end

Brick = Struct.new(:id, :a, :b) do
    def on_ground?
        a.on_ground? || b.on_ground?
    end

    def axis
        i = a.to_a.zip(b.to_a).index { |a,b| a != b }
        if i
            [:x, :y, :z][i]
        else
            # Arbitrarily say single cubes are x
            :x
        end
    end

    def coords
        (a[axis]..b[axis]).map do |n|
            c = a.dup
            c[axis] = n
            c
        end
    end

    def drop
        Brick.new(id, a.drop, b.drop)
    end
end

bricks = ARGF.each_line.each_with_index.map do |line, index|
    a, b = line.chomp.split("~").map { Pos.new(*_1.split(",").map(&:to_i)) }
    Brick.new(index, a, b)
end

def try_move(bricks)
    bricks_by_coord = {}
    bricks.each do |brick|
        brick.coords.each do |coord|
            if bricks_by_coord.include?(coord)
                raise "wtf"
            end
            bricks_by_coord[coord] = brick
        end
    end

    any_moved = false
    bricks = bricks.map do |brick|
        next brick if brick.on_ground?

        new_brick = brick.drop
        if new_brick.coords.any? { bricks_by_coord.include?(_1) && bricks_by_coord[_1] != brick }
            # Blocked
            brick
        else
            any_moved = true
            new_brick
        end
    end

    [bricks, any_moved]
end

# Settle
loop do
    bricks, any_moved = try_move(bricks)
    break unless any_moved
end

puts "Settled"

# Check
bricks.map do |brick|
    pp brick

    bricks_without = bricks.reject { _1 == brick }
    before = bricks_without.dup

    loop do
        bricks_without, any_moved = try_move(bricks_without)
        break unless any_moved
    end

    (bricks_without - before).count
end.sum.then { puts _1 }
