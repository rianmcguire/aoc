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

    def normalize
        Pos.new(x % (X_RANGE.max + 1), y % (Y_RANGE.max + 1))
    end

    def valid?
        n_pos = normalize
        (GRID[n_pos.y][n_pos.x] == "." || GRID[n_pos.y][n_pos.x] == "S")
    end

    def frame
        [x / (X_RANGE.max + 1), y / (Y_RANGE.max + 1)]
    end

    # def frame_shift(frame)
    #     Pos.new(x - frame[0] * (X_RANGE.max + 1), y - frame[1] * (Y_RANGE.max + 1))
    # end
end

DIRS = [:n, :s, :e, :w]

starting_pos = nil
GRID = ARGF.each_line.each_with_index.map do |line, y|
    line.chomp.chars.each_with_index.map do |c, x|
        if c == "S"
            starting_pos = Pos.new(x, y)
        end
        c
    end
end

Y_RANGE = (0..GRID.length - 1)
X_RANGE = (0..GRID.first.length - 1)

frames = {
    [0, 0] => Set.new([starting_pos]),
}

known_transitions = {}

100.times do |step|
    puts "step #{step} frames #{frames.length}"
    new_frames = Hash.new { |h,k| h[k] = Set.new }
    outs = Hash.new { |h,k| h[k] = Set.new }
    skip_outs = Set.new
    frames.each do |frame, positions|
        key = [positions, *DIRS.map { frames.fetch(Pos.new(*frame).step(_1).to_a, Set.new) }]

        if known_transitions.include?(key)
            new_frames[frame], outs[frame] = known_transitions[key]
            skip_outs << frame
        else
            # puts "simulating"
            positions.each do |pos|
                DIRS.each do |dir|
                    new_pos = pos.step(dir)
                    next unless new_pos.valid?

                    if new_pos.frame == [0, 0]
                        new_frames[frame] << new_pos
                    else
                        outs[frame] << new_pos
                    end
                end
            end
        end
    end

    outs.each do |source_frame, positions|
        positions.each do |new_pos|
            dest_frame = new_pos.frame.zip(source_frame).map { |a,b| a + b }
            if !skip_outs.include?(dest_frame)
                # puts "applying outs"
                new_frames[dest_frame] << new_pos.normalize
            end
        end
    end

    frames.each do |frame, positions|
        key = [positions, *DIRS.map { frames.fetch(Pos.new(*frame).step(_1).to_a, Set.new) }]

        if !known_transitions.include?(key)
            # puts "saving new transition"
            known_transitions[key] = [new_frames.fetch(frame), outs[frame]]
        end
    end

    frames = new_frames
end

# pp known_transitions.length

# pp frames
puts frames.values.sum(&:length)
# pp positions.length
