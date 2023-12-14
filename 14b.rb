#!/usr/bin/env ruby

Pos = Struct.new(:x, :y) do
    def step(dir)
        case dir
        when :n
            Pos.new(x, y - 1)
        when :s
            Pos.new(x, y + 1)
        when :e
            Pos.new(x + 1, y)
        when :w
            Pos.new(x - 1, y)
        end
    end
end

rocks = Set.new
rocks_by = {
    x: Hash.new { |h, k| h[k] = Set.new },
    y: Hash.new { |h, k| h[k] = Set.new },
}
blocks = Set.new

ARGF.each_line.each_with_index do |line, y|
    line.chomp.chars.each_with_index do |c, x|
        if c == "O"
            pos = Pos.new(x, y)
            rocks << pos
            rocks_by[:x][pos.x] << pos
            rocks_by[:y][pos.y] << pos
        elsif c == "#"
            blocks << Pos.new(x, y)
        end
    end
end

$max_x = max_x = (rocks + blocks).map(&:x).max
$max_y = max_y = (rocks + blocks).map(&:y).max

$known_states = {}

cycles = 1000000000
cycle = 0
loop do
    cycle += 1
    puts "cycle #{cycle}"
    [:n, :w, :s, :e].each do |dir|
        loop do
            any_moved = false

            range, axis = case dir
            when :n 
                [(1..max_y), :y]
            when :s
                [(0..max_y - 1).reverse_each, :y]
            when :e
                [(0..max_x - 1).reverse_each, :x]
            when :w
                [(1..max_x), :x]
            end
        
            range.each do |n|
                rocks_by[axis][n].each do |rock|
                    new_rock = rock.step(dir)
        
                    if !rocks.include?(new_rock) && !blocks.include?(new_rock)
                        rocks.delete rock
                        rocks_by[:x][rock.x].delete rock
                        rocks_by[:y][rock.y].delete rock

                        rocks << new_rock
                        rocks_by[:x][new_rock.x] << new_rock
                        rocks_by[:y][new_rock.y] << new_rock

                        any_moved = true
                    end
                end
            end

            break unless any_moved
        end
    end

    if prev = $known_states[rocks.dup]
        puts "at cycle #{cycle}"
        puts "previously seen at #{prev}"

        repeat_length = cycle - prev
        puts "repeat_length #{repeat_length}"

        remaining = cycles - cycle
        puts "remaining #{remaining}"

        skip_cycles = remaining / repeat_length

        cycle += skip_cycles * repeat_length

        puts "new cycle #{cycle}"
        $known_states = {}
    else
        $known_states[rocks.dup] = cycle
    end

    break if cycle == cycles
end

rocks.sum do |rock|
    max_y + 1 - rock.y
end.then { puts _1 }
