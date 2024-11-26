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

    def valid?
        (0..MAX).include?(x) && (0..MAX).include?(y)
    end
end
Node = Struct.new(:type, :pos, :energized) do
end
Beam = Struct.new(:pos, :dir) do
    def step
        self.pos = pos.step(dir)
    end
end

map = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        Node.new(c, Pos.new(x, y), Set.new)
    end
end

MAX = map.length - 1

def reset(map)
    map.flatten.each { _1.energized = Set.new }
end

[
    *(0..MAX).map { |x| Beam.new(Pos.new(x, 0), :s) },
    *(0..MAX).map { |x| Beam.new(Pos.new(x, MAX), :n) },
    *(0..MAX).map { |y| Beam.new(Pos.new(0, y), :e) },
    *(0..MAX).map { |y| Beam.new(Pos.new(MAX, y), :w) },
].map do |start_beam|
    reset(map)
    beams = [start_beam]

    loop do
        next_beams = []
        beams.each do |beam|
            node = map[beam.pos.y][beam.pos.x]
    
            if !node.energized.add?(beam.dir)
                next
            end
    
            case node.type
            when "."
                # Empty space
            when "|"
                if beam.dir == :e || beam.dir == :w
                    beam.dir = :n
    
                    new_beam = beam.dup
                    new_beam.dir = :s
                    next_beams << new_beam
                end
            when "-"
                if beam.dir == :n || beam.dir == :s
                    beam.dir = :e
    
                    new_beam = beam.dup
                    new_beam.dir = :w
                    next_beams << new_beam
                end
            when "/"
                beam.dir = case beam.dir
                when :n
                    :e
                when :e
                    :n
                when :s
                    :w
                when :w
                    :s
                end
            when "\\"
                beam.dir = case beam.dir
                when :n
                    :w
                when :e
                    :s
                when :s
                    :e
                when :w
                    :n
                end
            else
                raise "Unhandled: #{node.inspect}"
            end
    
            beam.step
    
            if !beam.pos.valid?
                next
            end
    
            next_beams << beam
        end
    
        beams = next_beams
        break if beams.empty?
    end
    
    map.flatten.count { !_1.energized.empty? }
end.max.then { puts _1 }
