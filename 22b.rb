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

bricks = bricks.sort_by { |b| [b.a.z, b.b.z].min }

def settle(bricks)
    # Assumes bricks are sorted in ascending minimum z order

    bricks_by_coord = {}
    bricks.each do |brick|
        brick.coords.each do |coord|
            if bricks_by_coord.include?(coord)
                raise "wtf"
            end
            bricks_by_coord[coord] = brick.id
        end
    end

    any_moved = false
    bricks = bricks.map do |brick|
        while !brick.on_ground?
            new_brick = brick.drop
            if coord = new_brick.coords.find { bricks_by_coord.include?(_1) && bricks_by_coord[_1] != brick.id }
                # Blocked
                break
            else
                any_moved = true

                brick.coords.each { bricks_by_coord.delete _1 }
                new_brick.coords.each { bricks_by_coord[_1] = brick.id }

                brick = new_brick
            end
        end

        brick
    end

    [bricks, any_moved]
end

# Initial settle
bricks, _ = settle(bricks)

# Test removal of each brick
bricks.map do |brick|
    bricks_without = bricks.reject { _1 == brick }
    before = bricks_without.dup

    bricks_without, _ = settle(bricks_without)

    (bricks_without - before).count
end.sum.then { puts _1 }
