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

$next_id = 0
$frame_ids = {}
$frames_by_id = {}
def cache_frame(positions)
    if $frame_ids.include?(positions)
        $frame_ids[positions]
    else
        id = ($next_id += 1)
        $frame_ids[positions] = id
        $frames_by_id[id] = positions
        id
    end
end
null_frame = cache_frame(Set.new)
initial_frame = cache_frame( Set.new([starting_pos]))
compact_frames = {
    [0, 0] => initial_frame,
}

known_transitions = {}

500.times do |step|
    puts "step #{step}"
    new_positions = Hash.new { |h,k| h[k] = Set.new }
    outs = Hash.new { |h,k| h[k] = Set.new }
    skip_outs = Set.new
    new_compact_frames = {}
    compact_frames.each do |frame, id|
        positions = $frames_by_id.fetch(id)

        key = [id, *DIRS.map { compact_frames.fetch(Pos.new(*frame).step(_1).to_a, null_frame) }]

        if known_transitions.include?(key)
            new_compact_frames[frame], outs[frame] = known_transitions[key]
            skip_outs << frame
        else
            positions.each do |pos|
                DIRS.each do |dir|
                    new_pos = pos.step(dir)
                    next unless new_pos.valid?

                    if new_pos.frame == [0, 0]
                        new_positions[frame] << new_pos
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
                new_positions[dest_frame] << new_pos.normalize
            end
        end
    end

    new_positions.each do |frame, positions|
        new_compact_frames[frame] = cache_frame(positions)
    end

    compact_frames.each do |frame, id|
        key = [id, *DIRS.map { compact_frames.fetch(Pos.new(*frame).step(_1).to_a, null_frame) }]

        if !known_transitions.include?(key)
            # puts "saving new transition"
            known_transitions[key] = [new_compact_frames.fetch(frame), outs[frame]]
        end
    end

    compact_frames = new_compact_frames
end

# pp known_transitions.length

puts "frame cache size: #{$frames_by_id.length}"

puts compact_frames.values.map { $frames_by_id[_1].length }.sum
